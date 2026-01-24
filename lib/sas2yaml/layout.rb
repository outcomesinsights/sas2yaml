# frozen_string_literal: true

require "yaml"
require_relative "field"
require_relative "sas_processor"
require_relative "sassifier"

module Sas2Yaml
  # Represents a parsed SAS layout with structured field access
  class Layout
    attr_reader :fields, :source_file

    # Create a Layout from a SAS file path
    def self.from_file(file_path)
      processor = SasProcessor.new(file_path)
      code = processor.lines.join("\n")
      sassifier = Sassifier.new(code, processor: processor)
      new(sassifier.hash, source_file: file_path)
    end

    # Create a Layout from a SAS content string
    def self.from_string(sas_content)
      # Write to a temp file since SasProcessor expects a file path
      require "tempfile"
      Tempfile.create(["sas2yaml", ".sas"]) do |f|
        f.write(sas_content)
        f.flush
        from_file(f.path)
      end
    end

    def initialize(hash, source_file: nil)
      @source_file = source_file
      @fields = hash.map do |_key, attrs|
        Field.new(
          name: attrs[:name],
          column: attrs[:column],
          length: attrs[:length],
          type: attrs[:type],
          format: attrs[:format],
          droppable: attrs[:droppable] || false
        )
      end
    end

    # Get a field by name
    def [](field_name)
      field_name = field_name.to_s
      @fields.find { |f| f.name == field_name }
    end

    # Number of fields
    def field_count
      @fields.length
    end

    # Calculate record length from fields
    def record_length
      return 0 if @fields.empty?
      last_field = @fields.max_by { |f| f.column + f.length }
      last_field.column + last_field.length - 1
    end

    # Fields that should not be dropped (actual data fields)
    def data_fields
      @fields.reject(&:droppable?)
    end

    # Convert to hash representation
    def to_hash
      result = {}
      @fields.each do |field|
        result[field.name.to_sym] = field.to_hash
      end
      result
    end

    # Convert to YAML string
    def to_yaml
      to_hash.to_yaml
    end

    # Convert to JSON string
    def to_json(*args)
      require "json"
      to_hash.to_json(*args)
    end

    def field_names
      @fields.map(&:name)
    end

    def each(&block)
      @fields.each(&block)
    end

    include Enumerable
  end
end
