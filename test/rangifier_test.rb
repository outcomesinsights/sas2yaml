# frozen_string_literal: true

require "test_helper"
require "sas2yaml/rangifier"

class RangifierTest < Minitest::Test
  def test_simple_range
    rangifier = Rangifier.new("mon1-mon3")
    assert_equal %w[mon1 mon2 mon3], rangifier.values
  end

  def test_large_range
    rangifier = Rangifier.new("field1-field10")
    expected = (1..10).map { |i| "field#{i}" }
    assert_equal expected, rangifier.values
  end

  def test_single_value_without_trailing_digits
    rangifier = Rangifier.new("single_field")
    assert_equal ["single_field"], rangifier.values
  end

  def test_range_with_semicolon
    rangifier = Rangifier.new("var1-var5;")
    assert_equal %w[var1 var2 var3 var4 var5], rangifier.values
  end

  def test_range_with_spaces
    rangifier = Rangifier.new("  item1 - item3  ")
    assert_equal %w[item1 item2 item3], rangifier.values
  end

  def test_range_with_leading_zeros_in_prefix
    rangifier = Rangifier.new("dgn_cd1-dgn_cd5")
    assert_equal %w[dgn_cd1 dgn_cd2 dgn_cd3 dgn_cd4 dgn_cd5], rangifier.values
  end

  def test_values_memoization
    rangifier = Rangifier.new("a1-a2")
    first_call = rangifier.values
    second_call = rangifier.values
    assert_same first_call, second_call
  end
end
