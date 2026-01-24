# frozen_string_literal: true

require_relative "sas_processor"
require_relative "sassifier"
require_relative "logging"
require "psych"
require "tmpdir"

module Sas2Yaml
  class AssembleCommand
    def initialize(arguments)
      @arguments = arguments
    end

    def execute
      @arguments.each do |sas_file|
        Sas2Yaml.logger.info("Processing #{sas_file}")
        processed_sas = SasProcessor.new(sas_file).lines.join("\n")
        sassy_file = File.join(Dir.tmpdir, File.basename(sas_file, '.*') + '.sassy')
        File.write(sassy_file, processed_sas)
        Sas2Yaml.logger.debug("Temp file at #{sassy_file}")
        sassy = Sassifier.new(processed_sas)
        Sas2Yaml.logger.info("Found #{sassy.hash.keys.length} columns")
        file = sas_file.gsub(/\..+$/, '.yml')
        File.write(file, sassy.hash.to_yaml)
      end
    end
  end
end
