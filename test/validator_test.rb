# frozen_string_literal: true

require "test_helper"

class ValidatorTest < Minitest::Test
  def test_valid_non_overlapping_fields
    fields = [
      Sas2Yaml::Field.new(name: "field1", column: 1, length: 5, type: :string, format: "$char5."),
      Sas2Yaml::Field.new(name: "field2", column: 6, length: 5, type: :string, format: "$char5."),
      Sas2Yaml::Field.new(name: "field3", column: 11, length: 5, type: :string, format: "$char5.")
    ]

    validator = Sas2Yaml::Validator.new(fields)
    result = validator.validate

    assert result.valid?
    assert_empty result.errors
  end

  def test_detects_overlapping_fields
    fields = [
      Sas2Yaml::Field.new(name: "field_a", column: 10, length: 11, type: :string, format: "$char11."),
      Sas2Yaml::Field.new(name: "field_b", column: 15, length: 11, type: :string, format: "$char11.")
    ]

    validator = Sas2Yaml::Validator.new(fields)
    result = validator.validate

    refute result.valid?
    assert_equal 1, result.errors.length
    assert_equal :overlap, result.errors.first[:type]
    assert_match(/overlap/, result.errors.first[:message])
    assert_equal "field_a", result.errors.first[:fields][0][:name]
    assert_equal "field_b", result.errors.first[:fields][1][:name]
  end

  def test_detects_multiple_overlaps
    fields = [
      Sas2Yaml::Field.new(name: "a", column: 1, length: 10, type: :string, format: "$char10."),
      Sas2Yaml::Field.new(name: "b", column: 5, length: 10, type: :string, format: "$char10."),
      Sas2Yaml::Field.new(name: "c", column: 12, length: 10, type: :string, format: "$char10.")
    ]

    validator = Sas2Yaml::Validator.new(fields)
    result = validator.validate

    refute result.valid?
    assert_equal 2, result.errors.length
  end

  def test_detects_gap_at_start
    fields = [
      Sas2Yaml::Field.new(name: "field1", column: 5, length: 5, type: :string, format: "$char5.")
    ]

    validator = Sas2Yaml::Validator.new(fields)
    result = validator.validate

    assert result.valid?  # Gaps are warnings, not errors
    assert_equal 1, result.warnings.length
    assert_equal :gap, result.warnings.first[:type]
    assert_match(/1-4/, result.warnings.first[:message])
  end

  def test_detects_gap_between_fields
    fields = [
      Sas2Yaml::Field.new(name: "field1", column: 1, length: 5, type: :string, format: "$char5."),
      Sas2Yaml::Field.new(name: "field2", column: 10, length: 5, type: :string, format: "$char5.")
    ]

    validator = Sas2Yaml::Validator.new(fields)
    result = validator.validate

    assert result.valid?
    assert_equal 1, result.warnings.length
    assert_equal :gap, result.warnings.first[:type]
    assert_match(/6-9/, result.warnings.first[:message])
  end

  def test_detects_field_exceeds_record_length
    fields = [
      Sas2Yaml::Field.new(name: "field1", column: 1, length: 5, type: :string, format: "$char5."),
      Sas2Yaml::Field.new(name: "field2", column: 6, length: 10, type: :string, format: "$char10.")
    ]

    validator = Sas2Yaml::Validator.new(fields, record_length: 10)
    result = validator.validate

    refute result.valid?
    assert_equal 1, result.errors.length
    assert_equal :exceeds_record_length, result.errors.first[:type]
    assert_equal "field2", result.errors.first[:field]
  end

  def test_valid_method
    valid_fields = [
      Sas2Yaml::Field.new(name: "field1", column: 1, length: 5, type: :string, format: "$char5.")
    ]

    invalid_fields = [
      Sas2Yaml::Field.new(name: "field1", column: 1, length: 10, type: :string, format: "$char10."),
      Sas2Yaml::Field.new(name: "field2", column: 5, length: 10, type: :string, format: "$char10.")
    ]

    assert Sas2Yaml::Validator.new(valid_fields).valid?
    refute Sas2Yaml::Validator.new(invalid_fields).valid?
  end

  def test_handles_empty_fields
    validator = Sas2Yaml::Validator.new([])
    result = validator.validate

    assert result.valid?
    assert_empty result.errors
    assert_empty result.warnings
  end

  def test_handles_single_field
    fields = [
      Sas2Yaml::Field.new(name: "only_field", column: 1, length: 10, type: :string, format: "$char10.")
    ]

    validator = Sas2Yaml::Validator.new(fields)
    result = validator.validate

    assert result.valid?
    assert_empty result.errors
    assert_empty result.warnings
  end
end

class LayoutValidationTest < Minitest::Test
  include TestFixtures

  def test_layout_validate_returns_result
    layout = Sas2Yaml.parse(fixture_path("simple.sas"))
    result = layout.validate

    assert_instance_of Sas2Yaml::Validator::ValidationResult, result
    assert result.respond_to?(:valid?)
    assert result.respond_to?(:errors)
    assert result.respond_to?(:warnings)
  end

  def test_layout_valid_method
    layout = Sas2Yaml.parse(fixture_path("simple.sas"))

    # The simple.sas fixture should be valid
    assert layout.valid?
  end

  def test_layout_with_overlapping_fields
    sas_content = <<~SAS
      data test;
      input
        @1 field1 10.
        @5 field2 10.
      ;
      run;
    SAS

    layout = Sas2Yaml.parse_string(sas_content)

    refute layout.valid?
    result = layout.validate
    assert_equal 1, result.errors.length
    assert_equal :overlap, result.errors.first[:type]
  end
end
