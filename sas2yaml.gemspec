# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sas2yaml/metadata"

Gem::Specification.new do |spec|
  spec.name          = "sas2yaml"
  spec.version       = Sas2Yaml::VERSION
  spec.authors       = ["Ryan Duryea"]
  spec.email         = ["aguynamedryan@gmail.com"]

  spec.summary       = Sas2Yaml::SUMMARY
  spec.description   = Sas2Yaml::DESCRIPTION
  spec.homepage      = "https://github.com/outcomesinsights/sas2yaml"

  spec.licenses      = ["MIT"]
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files         = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?("test/", ".git", ".github", "Gemfile")
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  # logger becomes a bundled gem in Ruby 4.0+
  spec.add_dependency "logger"

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", ">= 13.0"
end
