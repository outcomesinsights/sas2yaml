# Given an input of something like mon1-mon288
# will return %w(mon1 mon2 ... mon288) when #values is called
class Rangifier
  TRAILING_DIGITS_REGEXP = /(\d+)$/
  def initialize(input)
    @input = input
  end

  def values
    @values ||= get_values
  end

private
  def get_values
    parts = @input.sub(/;/, '').strip.split('-').map(&:strip)
    return [@input] unless parts.first =~ TRAILING_DIGITS_REGEXP
    puts "Rangifying #@input => #{parts}"
    first = parts.first.match(TRAILING_DIGITS_REGEXP)[1].to_i
    last = parts.last.match(TRAILING_DIGITS_REGEXP)[1].to_i
    prefix = parts.first.sub(TRAILING_DIGITS_REGEXP, '')
    puts "Ranging #{prefix} from #{first} - #{last}"
    (first..last).map { |i| "#{prefix}#{i}"}
  end
end
