require_relative 'rangifier'

# Translates SAS code into executable Ruby code
#
# This is a very gross translation and most code is skipped completely
# When I was looking at the SAS code to read in the ALL dataset, I noticed
# that I couldn't simply parse out each line and read the field information
# directly from the SAS file because sometimes the SAS file used loops
# to define the columns for some of the fields
#
# Also, some of the data type information was assigned to arrays in those
# loops.
#
# BUT I did notice that SAS looks a bit like Ruby and, with a little
# pruning and translating, the SAS code could be converted to Ruby
#
# So this class will parse a SAS file looking for the first line that
# starts with INPUT and will parse the file until it hits a line that
# says LABELs
#
# The resulting Ruby code uses instance variables to store all
# the information during processing.  This is to avoid problems where the
# SAS code is using reserved words or method names in Ruby.
# The SAS code frequently uses variable names like "begin" and "end" which are
# reserved words in Ruby and "inc" and "pos" which are common method names
#
# See below for information about how certain lines are handled
class SasProcessor
  @@def_regexp = /@[^;]/
  @@array_regexp = /array/
  @@label_start_regexp = /^label/i
  @@comment_regexp =%r{/\*.*?\*/}m
  @@blank_line_regexp = /^$/
  @@mode = :skip
  @@do_regexp = /^do /
  @@equals_regexp = /=/
  @@infile_regexp = /^infile\s+/i
  @@op_regexp = %r{([+-/=*]+)}

  def initialize(file_path)
    @file_path = file_path
  end

  # Given blah01-blah02 or (blah01-blah02)
  # Return ('blah01'..'blah02')
  def rangify(range)
    '%w(' + Rangifier.new(strip_parens(range)).values.join(' ') + ')'
  end

  # Given "(something)"
  # Return "something"
  def strip_parens(text)
    text.gsub(/[()]/, '')
  end

  # Given what could either be a variable name or a number literal, returns
  # either an instance variable with the same name, or the number literal
  # "001" => "1"
  # "var" => "@var"
  # "12var34" => "@12var34"
  def var_or_num(v_or_n)
    return v_or_n.gsub(/^0+(\d)/,'\1') if /^\d+$/.match(v_or_n)
    ivarify(v_or_n)
  end

  # Expect inputs like
  # cred10 which we just return
  # or (plan1-plan2) which we return as the range ('plan1'..'plan2')
  # or some_arr(2) which we return as @some_arr[2]
  def fix_name(text)
    return "'#{text}'" unless /\(/.match(text)
    return rangify(text) if /^\(/.match(text)
    ivarify(text.gsub(/\(([^)]+)\)/) do |match|
      '[' + var_or_num($1) + ']'
    end)
  end

  # Prepends "@" to the string
  def ivarify(var_name)
    '@' + var_name
  end

  # Definition lines start with "@111" or "input @pos + 2"
  # But either way, we're interested in everything after the @ sign
  # for these lines
  # Examples
  # @012  bic        $char2.
  # input @inc2 dgn(j)  $char5.
  def translate_def(line)
    # Strip up through the @
    line.gsub!(/^.*@/, '')
    parts = line.split(/\s+/)
    # Type information is always the last word on the line
    type = parts.pop
    # The name is always the second to the last word on the line
    name = fix_name(parts.pop)

    # The rest of the line could be as simple as a number literal or something like
    # (pos + 1)
    # So we put spaces between all the operators and then translate each part
    rest = blow_out_ops(strip_parens(parts.join(' '))).split(/\s+/).map { |w| var_or_num_or_op(w) }.join(' ')

    # Spit out Ruby code that will tranlate the contents of this definition line
    "at(#{rest}, #{name}, '#{type}')"
  end

  # SAS seems to be able to store input definitions into arrays
  # I don't know the mechanism, but I know how to translate it
  # We'll take a line like
  # array dgn(10) $ dgn_cd1-dgn_cd10;
  def translate_array(line)
    parts = line.split('$')
    # Last word has a ';' and then then a range that defines the field names
    # assigned to this array
    range = rangify(parts.pop.chop.sub(/^[\s\d]*/, ''))
    parts = parts.first.split(/\s+/)
    # We'll use the array's name as it appears in SAS to store the array
    # of field names
    # The array name starts as arr(10) so we'll chop off the part in parens
    puts parts[1]
    array_name = ivarify(parts[1].gsub(/\(.*/, ''))
    puts array_name
    # Spit out Ruby that assigns the array of field names to the array instance variable
    "#{array_name} = #{range}"
  end

  # Given do i = 1 to 24;
  # Return:
  #   (1..24).each do |i|
  #     @i = i
  def translate_do(line)
    parts = line.chop.split(/\s+/)
    lines = []
    finish = var_or_num(parts.pop)
    parts.pop # skip to
    start = var_or_num(parts.pop)
    parts.pop # skip equals
    var = parts.pop

    lines << "(#{start} - 1..#{finish} - 1).each do |#{var}|"
    lines << "\t#{ivarify(var)} = #{var}"
    lines.join("\n")
  end

  # Given a variable, number literal, or operator
  # return the appropriate translation
  # See var_or_num for variables and numbers
  # Operators are returned the same as they came in e.g.
  # "+" => "+"
  def var_or_num_or_op(vno)
    return vno if @@op_regexp.match(vno)
    var_or_num(vno)
  end

  # Places spaces around all operators so that
  # we can split on white space and pick up the operators as tokens
  def blow_out_ops(text)
    text.gsub(@@op_regexp, ' \1 ')
  end

  # Given a line that assigns a value to something on the left hand side
  # We need to do some basic translation of the line e.g.
  # "inc2=inc2+5;" => "@inc2 = @inc2 + 5"
  def translate_equals(line)
    blow_out_ops(line.chop).split(/\s+/).map { |w| var_or_num_or_op(w) }.join(' ')
  end

  def translate_infile(line)
    md = /lrecl\s*=\s*(\d+)/.match(line)
    puts md
    return "" if md.nil?
    return "record_len(#{md[1]})"
  end

  # This method processes the SAS file and translates all relevant lines
  def lines
    if @lines.nil?
      @lines = []
      @@mode = :skip
      File.open(@file_path).each_line do |l|
        # Strip out all comments from each line
        line = l.chomp.strip.gsub(@@comment_regexp, '')

        # Once we hit a line with "input", start processing
        @@mode = :process if line.match(/^input/i) || line.match(@@infile_regexp)
        next if @@mode == :skip

        # @; is ignorable, so make it a blank line
        line.gsub!(/@;/, '')

        # Skip blank lines
        next if line.match(@@blank_line_regexp)

        case line
        when @@def_regexp
          @lines << translate_def(line.downcase)
        when @@array_regexp
          @lines << translate_array(line.downcase)
        when @@do_regexp
          @lines << translate_do(line.downcase)
        when @@infile_regexp
          @lines << translate_infile(line.downcase)
        when @@equals_regexp
          @lines << translate_equals(line.downcase)
        when @@label_start_regexp
          # We hit the start of the labels, we can quit processing the file
          break
        when /^end;/
          @lines << line.chop.downcase
        end
      end
    end
    @lines
  end

  def save(file_path)
    File.open(file_path, 'w') do |f|
      f.puts lines.join("\n")
    end
  end
end
