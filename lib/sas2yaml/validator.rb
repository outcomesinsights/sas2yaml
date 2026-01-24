# frozen_string_literal: true

module Sas2Yaml
  # Validates field definitions for overlaps, gaps, and other issues
  class Validator
    ValidationResult = Struct.new(:valid?, :errors, :warnings, keyword_init: true)

    def initialize(fields, record_length: nil)
      @fields = fields
      @record_length = record_length
    end

    def validate
      errors = []
      warnings = []

      errors.concat(find_overlaps)
      warnings.concat(find_gaps)
      errors.concat(check_record_length) if @record_length

      ValidationResult.new(
        valid?: errors.empty?,
        errors: errors,
        warnings: warnings
      )
    end

    def valid?
      validate.valid?
    end

    private

    # Find fields that overlap (occupy the same columns)
    def find_overlaps
      errors = []
      sorted = @fields.sort_by(&:column)

      sorted.each_cons(2) do |field_a, field_b|
        end_a = field_a.column + field_a.length - 1
        start_b = field_b.column

        if end_a >= start_b
          overlap_start = start_b
          overlap_end = [end_a, field_b.column + field_b.length - 1].min
          errors << {
            type: :overlap,
            message: "Fields overlap at columns #{overlap_start}-#{overlap_end}",
            fields: [
              { name: field_a.name, columns: "#{field_a.column}-#{end_a}" },
              { name: field_b.name, columns: "#{start_b}-#{field_b.column + field_b.length - 1}" }
            ]
          }
        end
      end

      errors
    end

    # Find gaps between fields (columns with no field defined)
    def find_gaps
      warnings = []
      sorted = @fields.sort_by(&:column)

      # Check for gap at start (before first field)
      if sorted.any? && sorted.first.column > 1
        warnings << {
          type: :gap,
          message: "Gap detected at columns 1-#{sorted.first.column - 1} (no field defined)",
          columns: "1-#{sorted.first.column - 1}"
        }
      end

      # Check gaps between consecutive fields
      sorted.each_cons(2) do |field_a, field_b|
        end_a = field_a.column + field_a.length
        start_b = field_b.column

        if end_a < start_b
          warnings << {
            type: :gap,
            message: "Gap detected at columns #{end_a}-#{start_b - 1} (no field defined)",
            columns: "#{end_a}-#{start_b - 1}"
          }
        end
      end

      warnings
    end

    # Check if fields extend past the specified record length
    def check_record_length
      errors = []

      @fields.each do |field|
        field_end = field.column + field.length - 1
        if field_end > @record_length
          errors << {
            type: :exceeds_record_length,
            message: "Field '#{field.name}' extends past record length (ends at #{field_end}, record length is #{@record_length})",
            field: field.name,
            field_end: field_end,
            record_length: @record_length
          }
        end
      end

      errors
    end
  end
end
