# frozen_string_literal: true

require_relative "sas_processor"
require_relative "sassifier"
require_relative "formatters"
require_relative "logging"
require "tmpdir"

module Sas2Yaml
  class AssembleCommand
    def initialize(arguments, options = {})
      @arguments = arguments
      @format = options[:format] || "yaml"
      @table_name = options[:table_name]
    end

    def execute
      @arguments.each do |sas_file|
        Sas2Yaml.logger.info("Processing #{sas_file}")
        processor = SasProcessor.new(sas_file)
        processed_sas = processor.lines.join("\n")

        # Only write temp file in debug mode for debugging translation issues
        if Sas2Yaml.logger.debug?
          sassy_file = File.join(Dir.tmpdir, File.basename(sas_file, '.*') + '.sassy')
          File.write(sassy_file, processed_sas)
          Sas2Yaml.logger.debug("Temp file at #{sassy_file}")
        end

        sassy = Sassifier.new(processed_sas, processor: processor)
        Sas2Yaml.logger.info("Found #{sassy.hash.keys.length} columns")

        format_options = {}
        format_options[:table_name] = @table_name || derive_table_name(sas_file)

        output = Formatters.format(sassy.hash, @format, format_options)
        extension = Formatters.file_extension(@format)
        file = sas_file.gsub(/\.[^.]+$/, extension)
        File.write(file, output)
      end
    end

    private

    def derive_table_name(file_path)
      File.basename(file_path, ".*").downcase.gsub(/[^a-z0-9_]/, "_")
    end
  end
end
