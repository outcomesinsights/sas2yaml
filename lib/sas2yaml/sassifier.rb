require_relative "logging"
require_relative "parse_error"

# Runs the code that we generate by translating a SAS file into Ruby
#
# This class uses "eval" to get it's job done, so be wary about what code
# you feed it
class Sassifier
  def initialize(code, processor: nil)
    @_code = code
    @_processor = processor
  end

  def run
    Sas2Yaml.logger.debug("Generated Ruby code:\n#{@_code}")
    # eval the code, using the current class's context
    # so that the code has access to the class's supporting methods
    begin
      eval @_code, binding()
    rescue SyntaxError, StandardError => e
      raise build_parse_error(e)
    end
    check_record_length
    nil
  end

  private

  def build_parse_error(error)
    # Try to extract line number from eval error message
    # Format is typically "(eval):46: syntax error..."
    ruby_line = extract_ruby_line_from_error(error)
    sas_line = nil
    context_lines = []

    if @_processor && ruby_line
      sas_line = @_processor.line_mappings[ruby_line - 1]

      if sas_line && @_processor.original_lines.any?
        context_lines = build_context_lines(sas_line, @_processor.original_lines)
      end
    end

    ParseError.new(
      extract_error_description(error),
      file_path: @_processor&.file_path,
      line_number: sas_line,
      context_lines: context_lines,
      original_error: error
    )
  end

  def extract_ruby_line_from_error(error)
    if match = error.message.match(/\(eval\):(\d+):/)
      match[1].to_i
    end
  end

  def extract_error_description(error)
    # Remove the (eval):N: prefix from the message
    error.message.gsub(/^\(eval\):\d+:\s*/, '').strip
  end

  def build_context_lines(target_line, original_lines, context_size: 2)
    lines = []
    start_line = [target_line - context_size, 1].max
    end_line = [target_line + context_size, original_lines.length].min

    (start_line..end_line).each do |line_num|
      lines << {
        number: line_num,
        content: original_lines[line_num - 1] || "",
        current: line_num == target_line
      }
    end
    lines
  end

  public

  def check_record_length
    return if @record_length.nil?
    last_column = @_hash.values.last
    last_position = last_column[:column] + last_column[:length]
    return if last_position >= @record_length
    at(last_position, '_fill', (@record_length - last_position).to_s)
    @_hash.values.last[:droppable] = true
  end

  # Hash where we store the field information
  # Memoized so that we run the code to populate the hash on the
  # first attempt to access the hash
  def hash
    if @_hash.nil?
      @_hash = {}
      run
    end
    @_hash
  end

  # Given a SAS-orient type string, return the data type
  # '10.' => :integer
  # '15.2' => :decimal
  # All else seems to be string (so far)
  def get_type(type_str)
    return :integer if /^\d+\.$/.match(type_str)
    return :decimal if /^\d+\.\d+$/.match(type_str)
    return :string
  end

  # Given the same type string as described in get_type
  # Return the length
  # '10.' => 10
  # '15.2' => 15
  # '$char2' => 2
  def get_length(type_str)
    type_str.gsub(/^\D+/, '').to_i
  end

  # Given a column position, a set of names, and a type_str
  # store information about the field for each name
  def at(column, names, type_str)
    length = get_length(type_str)
    type = get_type(type_str)

    # If we receive a set of names, then we assume that the names represent
    # individual slices of a contiguous set of columns, all the same length
    #
    # So if we have column position of 1 and names %w(name1 name2) and a length of 2
    # then name1 is column 1, length 2 and name2 is column3 length 2
    if names.is_a?(Array)
      names.each do |name|
        at(column, name, type_str)
        column += length
      end
    else
      @_hash[names.to_sym] = {column: column, name: names, type: type, length: length, format: type_str}
    end
  end

  def record_len(length)
    @record_length = length
  end
end
