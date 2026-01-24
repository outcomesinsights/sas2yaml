# frozen_string_literal: true

require "test_helper"
require "sas2yaml/sas_processor"

class SasProcessorTest < Minitest::Test
  include TestFixtures

  def test_simple_sas_file_processing
    processor = SasProcessor.new(fixture_path("simple.sas"))
    lines = processor.lines

    assert_includes lines.join("\n"), "at(1, 'patient_id', '8.')"
    assert_includes lines.join("\n"), "at(9, 'age', '3.')"
    assert_includes lines.join("\n"), "at(12, 'gender', '$char1.')"
  end

  def test_extracts_record_length
    processor = SasProcessor.new(fixture_path("simple.sas"))
    lines = processor.lines

    assert_includes lines, "record_len(50)"
  end

  def test_rangify_simple_range
    processor = SasProcessor.new(fixture_path("simple.sas"))
    result = processor.rangify("mon1-mon3")

    assert_equal "%w(mon1 mon2 mon3)", result
  end

  def test_rangify_with_parentheses
    processor = SasProcessor.new(fixture_path("simple.sas"))
    result = processor.rangify("(field1-field2)")

    assert_equal "%w(field1 field2)", result
  end

  def test_strip_parens
    processor = SasProcessor.new(fixture_path("simple.sas"))

    assert_equal "something", processor.strip_parens("(something)")
    assert_equal "no parens", processor.strip_parens("no parens")
  end

  def test_var_or_num_with_number
    processor = SasProcessor.new(fixture_path("simple.sas"))

    assert_equal "1", processor.var_or_num("001")
    assert_equal "123", processor.var_or_num("123")
  end

  def test_var_or_num_with_variable
    processor = SasProcessor.new(fixture_path("simple.sas"))

    assert_equal "@myvar", processor.var_or_num("myvar")
    assert_equal "@inc2", processor.var_or_num("inc2")
  end

  def test_ivarify
    processor = SasProcessor.new(fixture_path("simple.sas"))

    assert_equal "@test", processor.ivarify("test")
  end

  def test_fix_name_simple
    processor = SasProcessor.new(fixture_path("simple.sas"))

    assert_equal "'cred10'", processor.fix_name("cred10")
  end

  def test_fix_name_with_array_index
    processor = SasProcessor.new(fixture_path("simple.sas"))

    assert_equal "@some_arr[2]", processor.fix_name("some_arr(2)")
  end

  def test_fix_name_with_range
    processor = SasProcessor.new(fixture_path("simple.sas"))
    result = processor.fix_name("(plan1-plan3)")

    assert_equal "%w(plan1 plan2 plan3)", result
  end

  def test_stops_at_label
    processor = SasProcessor.new(fixture_path("simple.sas"))
    lines = processor.lines

    refute lines.any? { |l| l.include?("Patient ID") }
  end

  def test_stops_at_indented_label
    processor = SasProcessor.new(fixture_path("with_indented_labels.sas"))
    lines = processor.lines

    # Should stop before label statements, even when indented
    refute lines.any? { |l| l.include?("Unique Record") }
    refute lines.any? { |l| l.include?("First Character") }

    # Should have parsed the actual field definitions
    assert lines.any? { |l| l.include?("'record_id'") }
    assert lines.any? { |l| l.include?("'final_field'") }
  end

  def test_strips_trailing_semicolon_from_format
    processor = SasProcessor.new(fixture_path("with_real_world_patterns.sas"))
    lines = processor.lines

    # The last field definition has a trailing semicolon that should be stripped
    # @00063 final_char  $char10.;
    assert lines.any? { |l| l.include?("'$char10.'") }
    refute lines.any? { |l| l.include?("'$char10.;'") }

    # Decimal format should also have semicolon stripped
    # @00057 decimal_field  6.4
    assert lines.any? { |l| l.include?("'6.4'") }
    refute lines.any? { |l| l.include?("'6.4;'") }
  end

  def test_handles_leading_zeros_in_column_numbers
    processor = SasProcessor.new(fixture_path("with_real_world_patterns.sas"))
    lines = processor.lines

    # @00001 should become at(1, ...)
    assert lines.any? { |l| l.include?("at(1,") }
    # @00016 should become at(16, ...)
    assert lines.any? { |l| l.include?("at(16,") }
    # @00031 should become at(31, ...)
    assert lines.any? { |l| l.include?("at(31,") }
  end
end
