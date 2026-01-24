# frozen_string_literal: true

require "sas2yaml/metadata"
require "sas2yaml/logging"
require "sas2yaml/parse_error"
require "sas2yaml/rangifier"
require "sas2yaml/sas_processor"
require "sas2yaml/sassifier"
require "sas2yaml/field"
require "sas2yaml/layout"
require "sas2yaml/formatters"

module Sas2Yaml
  class << self
    # Parse a SAS file and return a Layout object
    #
    # @param file_path [String] Path to the SAS file
    # @return [Layout] Parsed layout with field information
    def parse(file_path)
      Layout.from_file(file_path)
    end

    # Parse SAS content from a string and return a Layout object
    #
    # @param sas_content [String] SAS file content as a string
    # @return [Layout] Parsed layout with field information
    def parse_string(sas_content)
      Layout.from_string(sas_content)
    end
  end
end
