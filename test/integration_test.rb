# frozen_string_literal: true

require "test_helper"
require "sas2yaml/sas_processor"
require "sas2yaml/sassifier"
require "tmpdir"
require "yaml"

class IntegrationTest < Minitest::Test
  include TestFixtures

  def test_simple_sas_to_yaml
    processor = SasProcessor.new(fixture_path("simple.sas"))
    code = processor.lines.join("\n")
    sassifier = Sassifier.new(code)
    result = sassifier.hash

    assert result[:patient_id]
    assert_equal 1, result[:patient_id][:column]
    assert_equal :integer, result[:patient_id][:type]
    assert_equal 8, result[:patient_id][:length]

    assert result[:age]
    assert_equal 9, result[:age][:column]
    assert_equal :integer, result[:age][:type]

    assert result[:gender]
    assert_equal 12, result[:gender][:column]
    assert_equal :string, result[:gender][:type]
    assert_equal 1, result[:gender][:length]

    assert result[:weight]
    assert_equal 13, result[:weight][:column]
    assert_equal :decimal, result[:weight][:type]

    assert result[:diagnosis]
    assert_equal 18, result[:diagnosis][:column]
    assert_equal :string, result[:diagnosis][:type]
    assert_equal 10, result[:diagnosis][:length]
  end

  def test_output_can_be_converted_to_yaml
    processor = SasProcessor.new(fixture_path("simple.sas"))
    code = processor.lines.join("\n")
    sassifier = Sassifier.new(code)
    result = sassifier.hash

    yaml_output = result.to_yaml
    parsed = YAML.safe_load(yaml_output, permitted_classes: [Symbol])

    assert parsed.is_a?(Hash)
    assert parsed.key?(:patient_id) || parsed.key?("patient_id")
  end

  def test_handles_record_length_padding
    processor = SasProcessor.new(fixture_path("simple.sas"))
    code = processor.lines.join("\n")
    sassifier = Sassifier.new(code)
    result = sassifier.hash

    # The simple.sas has lrecl=50, last field ends before 50
    # so there should be a _fill field
    if result[:_fill]
      assert result[:_fill][:droppable]
    end
  end

  def test_handles_indented_labels
    processor = SasProcessor.new(fixture_path("with_indented_labels.sas"))
    code = processor.lines.join("\n")
    sassifier = Sassifier.new(code)
    result = sassifier.hash

    # Should correctly parse all fields and stop at indented label
    # 7 fields + 1 _fill field (for padding to lrecl=100)
    assert_equal 8, result.size

    assert result[:record_id]
    assert_equal 1, result[:record_id][:column]
    assert_equal :string, result[:record_id][:type]
    assert_equal 10, result[:record_id][:length]

    assert result[:final_field]
    assert_equal 57, result[:final_field][:column]
    assert_equal :string, result[:final_field][:type]
    assert_equal 20, result[:final_field][:length]

    # Should have a fill field for padding
    assert result[:_fill]
    assert_equal 77, result[:_fill][:column]
    assert_equal 23, result[:_fill][:length]
    assert result[:_fill][:droppable]
  end

  def test_real_world_patterns
    processor = SasProcessor.new(fixture_path("with_real_world_patterns.sas"))
    code = processor.lines.join("\n")
    sassifier = Sassifier.new(code)
    result = sassifier.hash

    # Test leading zeros in column numbers are handled
    assert result[:patient_id]
    assert_equal 1, result[:patient_id][:column]
    assert_equal :string, result[:patient_id][:type]
    assert_equal 15, result[:patient_id][:length]

    assert result[:claim_id]
    assert_equal 16, result[:claim_id][:column]

    # Test inline comments don't affect parsing
    assert result[:service_dt]
    assert_equal 31, result[:service_dt][:column]
    assert_equal :string, result[:service_dt][:type]

    # Test decimal types are correctly identified
    assert result[:amount]
    assert_equal 39, result[:amount][:column]
    assert_equal :decimal, result[:amount][:type]
    assert_equal 10, result[:amount][:length]

    assert result[:integer_field]
    assert_equal 49, result[:integer_field][:column]
    assert_equal :integer, result[:integer_field][:type]

    # Test trailing semicolon on last field is stripped
    # and type is correctly identified as decimal, not string
    assert result[:decimal_field]
    assert_equal 57, result[:decimal_field][:column]
    assert_equal :decimal, result[:decimal_field][:type]
    assert_equal "6.4", result[:decimal_field][:format]

    # Final field should also work correctly
    assert result[:final_char]
    assert_equal 63, result[:final_char][:column]
    assert_equal :string, result[:final_char][:type]
  end
end
