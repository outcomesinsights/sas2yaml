# Custom exception for SAS parsing failures with context
class ParseError < StandardError
  attr_reader :file_path, :line_number, :context_lines, :original_error

  def initialize(message, file_path: nil, line_number: nil, context_lines: [], original_error: nil)
    @file_path = file_path
    @line_number = line_number
    @context_lines = context_lines
    @original_error = original_error
    super(build_message(message))
  end

  private

  def build_message(message)
    parts = []

    if file_path && line_number
      parts << "Failed to parse '#{file_path}' at line #{line_number}"
    elsif file_path
      parts << "Failed to parse '#{file_path}'"
    end

    parts << "  #{message}" unless message.empty?

    if context_lines.any?
      parts << ""
      parts << "  Context:"
      context_lines.each do |ctx|
        marker = ctx[:current] ? ">" : " "
        parts << "  #{marker} #{ctx[:number].to_s.rjust(4)}: #{ctx[:content]}"
      end
    end

    if original_error
      parts << ""
      parts << "  Original error: #{original_error.class}: #{original_error.message}"
    end

    parts.join("\n")
  end
end
