# frozen_string_literal: true

require "test_helper"

class FieldTest < Minitest::Test
  def test_field_attributes
    field = Sas2Yaml::Field.new(
      name: "patient_id",
      column: 1,
      length: 8,
      type: :integer,
      format: "8."
    )

    assert_equal "patient_id", field.name
    assert_equal 1, field.column
    assert_equal 8, field.length
    assert_equal :integer, field.type
    assert_equal "8.", field.format
    refute field.droppable?
  end

  def test_droppable_field
    field = Sas2Yaml::Field.new(
      name: "_fill",
      column: 100,
      length: 10,
      type: :string,
      format: "10.",
      droppable: true
    )

    assert field.droppable?
  end

  def test_to_hash
    field = Sas2Yaml::Field.new(
      name: "age",
      column: 9,
      length: 3,
      type: :integer,
      format: "3."
    )

    expected = {
      name: "age",
      column: 9,
      length: 3,
      type: :integer,
      format: "3."
    }
    assert_equal expected, field.to_hash
  end

  def test_to_hash_with_droppable
    field = Sas2Yaml::Field.new(
      name: "_fill",
      column: 100,
      length: 10,
      type: :string,
      format: "10.",
      droppable: true
    )

    hash = field.to_hash
    assert_equal true, hash[:droppable]
  end

  def test_equality
    field1 = Sas2Yaml::Field.new(
      name: "test",
      column: 1,
      length: 5,
      type: :string,
      format: "$char5."
    )
    field2 = Sas2Yaml::Field.new(
      name: "test",
      column: 1,
      length: 5,
      type: :string,
      format: "$char5."
    )
    field3 = Sas2Yaml::Field.new(
      name: "other",
      column: 1,
      length: 5,
      type: :string,
      format: "$char5."
    )

    assert_equal field1, field2
    refute_equal field1, field3
  end

  def test_to_s
    field = Sas2Yaml::Field.new(
      name: "patient_id",
      column: 1,
      length: 8,
      type: :integer,
      format: "8."
    )

    assert_match(/Sas2Yaml::Field/, field.to_s)
    assert_match(/patient_id/, field.to_s)
  end
end
