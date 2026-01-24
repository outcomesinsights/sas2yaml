# frozen_string_literal: true

require "test_helper"
require "sas2yaml/parse_error"

class ParseErrorTest < Minitest::Test
  def test_basic_error_message
    error = ParseError.new("unexpected token")

    assert_match(/unexpected token/, error.message)
  end

  def test_error_with_file_and_line
    error = ParseError.new(
      "unexpected token",
      file_path: "input.sas",
      line_number: 42
    )

    assert_equal "input.sas", error.file_path
    assert_equal 42, error.line_number
    assert_match(/Failed to parse 'input.sas' at line 42/, error.message)
    assert_match(/unexpected token/, error.message)
  end

  def test_error_with_context_lines
    context = [
      { number: 41, content: "  @00360 SUBMSN_CLR_CD  $char2.", current: false },
      { number: 42, content: "  ;", current: false },
      { number: 43, content: "  label PDE_ID = \"test\"", current: true },
      { number: 44, content: "  next line", current: false }
    ]

    error = ParseError.new(
      "unexpected content",
      file_path: "test.sas",
      line_number: 43,
      context_lines: context
    )

    assert_match(/Context:/, error.message)
    assert_match(/>   43:/, error.message)  # Current line marked with >
    assert_match(/    41:/, error.message)   # Other lines not marked
  end

  def test_error_with_original_error
    original = SyntaxError.new("original syntax error")
    error = ParseError.new(
      "unexpected token",
      original_error: original
    )

    assert_equal original, error.original_error
    assert_match(/Original error: SyntaxError/, error.message)
  end

  def test_error_is_standard_error
    error = ParseError.new("test")

    assert_kind_of StandardError, error
  end
end
