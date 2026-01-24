# frozen_string_literal: true

require "test_helper"

class LabelExtractionTest < Minitest::Test
  include TestFixtures

  def test_extracts_labels_from_simple_file
    layout = Sas2Yaml.parse(fixture_path("simple.sas"))

    patient_id = layout["patient_id"]
    assert_equal "Patient ID", patient_id.label

    age = layout["age"]
    assert_equal "Age in years", age.label

    # Fields without labels should have nil
    gender = layout["gender"]
    assert_nil gender.label
  end

  def test_extracts_labels_from_indented_labels
    layout = Sas2Yaml.parse(fixture_path("with_indented_labels.sas"))

    record_id = layout["record_id"]
    assert_equal "Unique Record Identifier", record_id.label

    field_a = layout["field_a"]
    assert_equal "First Character Field", field_a.label

    numeric_field = layout["numeric_field"]
    assert_equal "An Integer Field", numeric_field.label
  end

  def test_label_included_in_to_hash
    layout = Sas2Yaml.parse(fixture_path("simple.sas"))
    hash = layout.to_hash

    assert_equal "Patient ID", hash[:patient_id][:label]
    assert_equal "Age in years", hash[:age][:label]
    # Fields without labels should not have :label key
    refute hash[:gender].key?(:label)
  end

  def test_label_included_in_field_to_hash
    field = Sas2Yaml::Field.new(
      name: "test",
      column: 1,
      length: 5,
      type: :string,
      format: "$char5.",
      label: "Test Description"
    )

    hash = field.to_hash
    assert_equal "Test Description", hash[:label]
  end

  def test_field_without_label_omits_from_hash
    field = Sas2Yaml::Field.new(
      name: "test",
      column: 1,
      length: 5,
      type: :string,
      format: "$char5."
    )

    hash = field.to_hash
    refute hash.key?(:label)
  end

  def test_sas_processor_labels_hash
    processor = SasProcessor.new(fixture_path("simple.sas"))
    processor.lines  # Trigger parsing

    assert_equal "Patient ID", processor.labels["patient_id"]
    assert_equal "Age in years", processor.labels["age"]
  end

  def test_parse_string_with_labels
    sas_content = <<~SAS
      data test;
      input
        @1 id 5.
        @6 name $char10.
      ;
      label
        id = "Record ID"
        name = "Full Name"
      ;
      run;
    SAS

    layout = Sas2Yaml.parse_string(sas_content)

    assert_equal "Record ID", layout["id"].label
    assert_equal "Full Name", layout["name"].label
  end

  def test_labels_with_single_quotes
    sas_content = <<~SAS
      data test;
      input @1 field1 5.;
      label field1 = 'Single quoted label';
      run;
    SAS

    layout = Sas2Yaml.parse_string(sas_content)

    assert_equal "Single quoted label", layout["field1"].label
  end
end
