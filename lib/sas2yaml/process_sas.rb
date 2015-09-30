# Script that drives processing each SAS file to glean the field type
# information e.g.
# Column position
# Length
# Format
# Data type

require 'psych'
require 'fileutils'
require 'tmpdir'

require_relative '../parsers/sas/sas_processor'
require_relative '../parsers/sas/sassifier'

module ProcessSas
  extend self

  def run
    dir = 'ddls'
    FileUtils.mkdir(dir) unless File.exist?(dir)
    Dir.glob("sas/*").each do |sas_file|
      puts "=" * 90
      puts sas_file
      puts "=" * 90
      processed_sas = SasProcessor.new(sas_file).lines.join("\n")
      sassy = Sassifier.new(processed_sas)
      puts "NUM COLUMNS: #{sassy.hash.keys.length}"
      file = File.join(dir, sas_file.gsub(/.+\//, '').gsub(/\..+$/, '.yml'))
      File.open(file, 'w') { |f| f.puts sassy.hash.to_yaml }

      File.write(File.join(Dir.tmpdir, File.basename(file, '.*') + '.sassy'), processed_sas)
    end
  end
end
