# frozen_string_literal: true

module Sas2Yaml
  # Represents a single field in a SAS layout
  class Field
    attr_reader :name, :column, :length, :type, :format, :droppable

    def initialize(name:, column:, length:, type:, format:, droppable: false)
      @name = name
      @column = column
      @length = length
      @type = type
      @format = format
      @droppable = droppable
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
      }.tap { |h| h[:droppable] = true if @droppable }
    end

    def ==(other)
      return false unless other.is_a?(Field)
      name == other.name &&
        column == other.column &&
        length == other.length &&
        type == other.type &&
        format == other.format &&
        droppable == other.droppable
    end

    def to_s
      "#<Sas2Yaml::Field name=#{@name.inspect} column=#{@column} length=#{@length} type=#{@type.inspect}>"
    end
    alias inspect to_s
  end
end
