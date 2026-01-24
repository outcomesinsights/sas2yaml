# frozen_string_literal: true

module Sas2Yaml
  # Represents a single field in a SAS layout
  class Field
    attr_reader :name, :column, :length, :type, :format, :droppable, :label

    def initialize(name:, column:, length:, type:, format:, droppable: false, label: nil)
      @name = name
      @column = column
      @length = length
      @type = type
      @format = format
      @droppable = droppable
      @label = label
    end

    def droppable?
      @droppable
    end

    def to_hash
      {
        name: @name,
        column: @column,
        length: @length,
        type: @type,
        format: @format
      }.tap do |h|
        h[:droppable] = true if @droppable
        h[:label] = @label if @label
      end
    end

    def ==(other)
      return false unless other.is_a?(Field)
      name == other.name &&
        column == other.column &&
        length == other.length &&
        type == other.type &&
        format == other.format &&
        droppable == other.droppable &&
        label == other.label
    end

    def to_s
      "#<Sas2Yaml::Field name=#{@name.inspect} column=#{@column} length=#{@length} type=#{@type.inspect}>"
    end
    alias inspect to_s
  end
end
