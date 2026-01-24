# frozen_string_literal: true

require "test_helper"
require "json"

class FormattersTest < Minitest::Test
  def setup
    @hash = {
      patient_id: { name: "patient_id", column: 1, length: 8, type: :integer, format: "8.", label: "Patient ID" },
      name: { name: "name", column: 9, length: 20, type: :string, format: "$char20." },
      amount: { name: "amount", column: 29, length: 10, type: :decimal, format: "10.2", label: "Payment Amount" }
    }
  end

  def test_yaml_format
    output = Sas2Yaml::Formatters.format(@hash, "yaml")

    assert_instance_of String, output
    parsed = YAML.safe_load(output, permitted_classes: [Symbol])
    assert parsed.key?(:patient_id) || parsed.key?("patient_id")
  end

  def test_json_format
    output = Sas2Yaml::Formatters.format(@hash, "json")

    assert_instance_of String, output
    parsed = JSON.parse(output)
    assert parsed.key?("patient_id")
    assert_equal "patient_id", parsed["patient_id"]["name"]
    assert_equal 1, parsed["patient_id"]["column"]
  end

  def test_csv_format
    output = Sas2Yaml::Formatters.format(@hash, "csv")

    assert_instance_of String, output
    lines = output.strip.split("\n")
    assert_equal "name,column,length,type,format,label", lines[0]
    assert_match(/patient_id,1,8,integer,8\.,Patient ID/, lines[1])
  end

  def test_sql_format_with_default_table_name
    output = Sas2Yaml::Formatters.format(@hash, "sql")

    assert_match(/CREATE TABLE table_name/, output)
    assert_match(/patient_id INTEGER -- Patient ID/, output)
    assert_match(/name VARCHAR\(20\),/, output)  # No comment for field without label
    assert_match(/amount DECIMAL\(10, 2\) -- Payment Amount/, output)
  end

  def test_sql_format_with_custom_table_name
    output = Sas2Yaml::Formatters.format(@hash, "sql", table_name: "patients")

    assert_match(/CREATE TABLE patients/, output)
  end

  def test_unknown_format_raises_error
    assert_raises(ArgumentError) do
      Sas2Yaml::Formatters.format(@hash, "xml")
    end
  end

  def test_file_extensions
    assert_equal ".yml", Sas2Yaml::Formatters.file_extension("yaml")
    assert_equal ".json", Sas2Yaml::Formatters.file_extension("json")
    assert_equal ".csv", Sas2Yaml::Formatters.file_extension("csv")
    assert_equal ".sql", Sas2Yaml::Formatters.file_extension("sql")
  end

  def test_formats_constant
    assert_includes Sas2Yaml::Formatters::FORMATS, "yaml"
    assert_includes Sas2Yaml::Formatters::FORMATS, "json"
    assert_includes Sas2Yaml::Formatters::FORMATS, "csv"
    assert_includes Sas2Yaml::Formatters::FORMATS, "sql"
  end

  def test_case_insensitive_format
    output_lower = Sas2Yaml::Formatters.format(@hash, "json")
    output_upper = Sas2Yaml::Formatters.format(@hash, "JSON")

    assert_equal output_lower, output_upper
  end
end
