require_relative 'sas_processor'
require_relative 'sassifier'
require 'psych'

module Sas2Yaml
  class AssembleCommand < ::Escort::ActionCommand::Base
    def execute
      arguments.each do |sas_file|
        puts "Processing #{sas_file}"
        processed_sas = SasProcessor.new(sas_file).lines.join("\n")
        sassy_file = File.join(Dir.tmpdir, File.basename(sas_file, '.*') + '.sassy')
        File.write(sassy_file, processed_sas)
        puts "Temp at  #{sassy_file}"
        sassy = Sassifier.new(processed_sas)
        puts "NUM COLUMNS: #{sassy.hash.keys.length}"
        file = sas_file.gsub(/\..+$/, '.yml')
        File.write(file, sassy.hash.to_yaml)
      end
    end
  end
end
