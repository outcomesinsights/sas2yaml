# frozen_string_literal: true

require "test_helper"

class ApiTest < Minitest::Test
  include TestFixtures

  def test_parse_file
    layout = Sas2Yaml.parse(fixture_path("simple.sas"))

    assert_instance_of Sas2Yaml::Layout, layout
    # 5 data fields + 1 _fill field (due to lrecl=50)
    assert_equal 6, layout.field_count
    assert_equal 5, layout.data_fields.length
  end

  def test_parse_string
    sas_content = <<~SAS
      data test;
      input
        @1 field1 5.
        @6 field2 $char10.
      ;
      run;
    SAS

    layout = Sas2Yaml.parse_string(sas_content)

    assert_instance_of Sas2Yaml::Layout, layout
    assert_equal 2, layout.field_count
    assert_includes layout.field_names, "field1"
    assert_includes layout.field_names, "field2"
  end

  def test_full_workflow
    # This tests the documented API from the issue
    layout = Sas2Yaml.parse(fixture_path("simple.sas"))

    # Access fields
    assert layout.fields.any?

    # Get record length
    assert layout.record_length > 0

    # Convert to YAML
    yaml = layout.to_yaml
    assert_instance_of String, yaml

    # Convert to hash
    hash = layout.to_hash
    assert_instance_of Hash, hash
  end
end
