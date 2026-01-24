# frozen_string_literal: true

require "yaml"
require "json"
require "csv"

module Sas2Yaml
  module Formatters
    FORMATS = %w[yaml json csv sql].freeze

    class << self
      def format(hash, format_name, options = {})
        case format_name.to_s.downcase
        when "yaml"
          YamlFormatter.format(hash)
        when "json"
          JsonFormatter.format(hash)
        when "csv"
          CsvFormatter.format(hash)
        when "sql"
          SqlFormatter.format(hash, options)
        else
          raise ArgumentError, "Unknown format: #{format_name}. Valid formats: #{FORMATS.join(', ')}"
        end
      end

      def file_extension(format_name)
        case format_name.to_s.downcase
        when "yaml" then ".yml"
        when "json" then ".json"
        when "csv" then ".csv"
        when "sql" then ".sql"
        else ".yml"
        end
      end
    end

    module YamlFormatter
      def self.format(hash)
        hash.to_yaml
      end
    end

    module JsonFormatter
      def self.format(hash)
        JSON.pretty_generate(hash)
      end
    end

    module CsvFormatter
      def self.format(hash)
        CSV.generate do |csv|
          csv << %w[name column length type format label]
          hash.each do |_key, field|
            csv << [
              field[:name],
              field[:column],
              field[:length],
              field[:type],
              field[:format],
              field[:label]
            ]
          end
        end
      end
    end

    module SqlFormatter
      def self.format(hash, options = {})
        table_name = options[:table_name] || "table_name"
        columns = hash.map do |_key, field|
          sql_type = case field[:type]
          when :integer then "INTEGER"
          when :decimal then "DECIMAL(#{field[:length]}, 2)"
          when :string then "VARCHAR(#{field[:length]})"
          else "VARCHAR(#{field[:length]})"
          end
          comment = field[:label] ? " -- #{field[:label]}" : ""
          "  #{field[:name]} #{sql_type}#{comment}"
        end

        "CREATE TABLE #{table_name} (\n#{columns.join(",\n")}\n);"
      end
    end
  end
end
