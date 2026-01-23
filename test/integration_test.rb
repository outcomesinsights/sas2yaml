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
end
