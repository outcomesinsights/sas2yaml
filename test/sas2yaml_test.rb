# frozen_string_literal: true

require "test_helper"

class Sas2YamlTest < Minitest::Test
  def test_version_is_defined
    refute_nil Sas2Yaml::VERSION
  end

  def test_summary_is_defined
    refute_nil Sas2Yaml::SUMMARY
  end

  def test_description_is_defined
    refute_nil Sas2Yaml::DESCRIPTION
  end
end
