# frozen_string_literal: true

require "test_helper"

class LayoutTest < Minitest::Test
  include TestFixtures

  def test_from_file
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))

    # 5 data fields + 1 _fill field (due to lrecl=50)
    assert_equal 6, layout.field_count
    assert_equal 5, layout.data_fields.length
    assert_includes layout.field_names, "patient_id"
    assert_includes layout.field_names, "age"
    assert_includes layout.field_names, "gender"
  end

  def test_from_string
    sas_content = <<~SAS
      data test;
      input
        @1 id 5.
        @6 name $char10.
      ;
      label id = "ID";
      run;
    SAS

    layout = Sas2Yaml::Layout.from_string(sas_content)

    assert_equal 2, layout.field_count
    assert_includes layout.field_names, "id"
    assert_includes layout.field_names, "name"
  end

  def test_bracket_access
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))

    field = layout["patient_id"]
    assert_instance_of Sas2Yaml::Field, field
    assert_equal "patient_id", field.name
    assert_equal 1, field.column
    assert_equal 8, field.length
    assert_equal :integer, field.type
  end

  def test_bracket_access_with_symbol
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))

    field = layout[:age]
    assert_instance_of Sas2Yaml::Field, field
    assert_equal "age", field.name
  end

  def test_bracket_access_missing_field
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))

    assert_nil layout["nonexistent"]
  end

  def test_record_length
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))

    # lrecl=50 adds a _fill field, so record length is 49 (50 - 1, since columns are 1-based)
    assert_equal 49, layout.record_length
  end

  def test_to_hash
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))
    hash = layout.to_hash

    assert_instance_of Hash, hash
    assert hash.key?(:patient_id)
    assert_equal "patient_id", hash[:patient_id][:name]
    assert_equal 1, hash[:patient_id][:column]
  end

  def test_to_yaml
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))
    yaml = layout.to_yaml

    assert_instance_of String, yaml
    assert_match(/patient_id/, yaml)
    assert_match(/column:/, yaml)
  end

  def test_to_json
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))
    json = layout.to_json

    assert_instance_of String, json
    parsed = JSON.parse(json)
    assert parsed.key?("patient_id")
  end

  def test_enumerable
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))

    names = layout.map(&:name)
    assert_includes names, "patient_id"
    assert_includes names, "age"
  end

  def test_data_fields_excludes_droppable
    sas_content = <<~SAS
      data test;
      infile 'data.dat' lrecl=20;
      input
        @1 id 5.
      ;
      run;
    SAS

    layout = Sas2Yaml::Layout.from_string(sas_content)

    # The layout should have a _fill field due to lrecl padding
    all_count = layout.field_count
    data_count = layout.data_fields.length

    # If there's padding, data_fields should be fewer
    assert data_count <= all_count
    refute layout.data_fields.any?(&:droppable?)
  end

  def test_source_file
    layout = Sas2Yaml::Layout.from_file(fixture_path("simple.sas"))

    assert_equal fixture_path("simple.sas"), layout.source_file
  end
end
