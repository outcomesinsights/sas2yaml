# frozen_string_literal: true

require "test_helper"
require "sas2yaml/sassifier"

class SassifierTest < Minitest::Test
  def test_simple_field_definition
    code = "at(1, 'patient_id', '8.')"
    sassifier = Sassifier.new(code)
    result = sassifier.hash

    assert_equal 1, result.size
    assert_equal({ column: 1, name: "patient_id", type: :integer, length: 8, format: "8." }, result[:patient_id])
  end

  def test_multiple_fields
    code = <<~RUBY
      at(1, 'id', '5.')
      at(6, 'name', '$char10.')
      at(16, 'amount', '8.2')
    RUBY

    sassifier = Sassifier.new(code)
    result = sassifier.hash

    assert_equal 3, result.size
    assert_equal :integer, result[:id][:type]
    assert_equal :string, result[:name][:type]
    assert_equal :decimal, result[:amount][:type]
  end

  def test_get_type_integer
    sassifier = Sassifier.new("")

    assert_equal :integer, sassifier.get_type("10.")
    assert_equal :integer, sassifier.get_type("3.")
  end

  def test_get_type_decimal
    sassifier = Sassifier.new("")

    assert_equal :decimal, sassifier.get_type("15.2")
    assert_equal :decimal, sassifier.get_type("8.3")
  end

  def test_get_type_string
    sassifier = Sassifier.new("")

    assert_equal :string, sassifier.get_type("$char10.")
    assert_equal :string, sassifier.get_type("$10.")
  end

  def test_get_length
    sassifier = Sassifier.new("")

    assert_equal 10, sassifier.get_length("10.")
    assert_equal 15, sassifier.get_length("15.2")
    assert_equal 2, sassifier.get_length("$char2.")
    assert_equal 5, sassifier.get_length("$5.")
  end

  def test_array_of_names
    code = "at(1, %w(field1 field2 field3), '3.')"
    sassifier = Sassifier.new(code)
    result = sassifier.hash

    assert_equal 3, result.size
    assert_equal({ column: 1, name: "field1", type: :integer, length: 3, format: "3." }, result[:field1])
    assert_equal({ column: 4, name: "field2", type: :integer, length: 3, format: "3." }, result[:field2])
    assert_equal({ column: 7, name: "field3", type: :integer, length: 3, format: "3." }, result[:field3])
  end

  def test_record_length_with_padding
    code = <<~RUBY
      record_len(20)
      at(1, 'field', '10.')
    RUBY

    sassifier = Sassifier.new(code)
    result = sassifier.hash

    assert_equal 2, result.size
    assert result[:_fill]
    assert_equal true, result[:_fill][:droppable]
    assert_equal 11, result[:_fill][:column]
    assert_equal 9, result[:_fill][:length]
  end

  def test_hash_memoization
    sassifier = Sassifier.new("at(1, 'test', '5.')")
    first_call = sassifier.hash
    second_call = sassifier.hash

    assert_same first_call, second_call
  end
end
