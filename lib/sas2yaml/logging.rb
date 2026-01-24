# frozen_string_literal: true

require "logger"

module Sas2Yaml
  # Module-level logger for the sas2yaml gem.
  # Default log level is WARN (quiet mode).
  # Use Sas2Yaml.verbose! to enable debug output.
  module Logging
    class << self
      def logger
        @logger ||= create_logger
      end

      def logger=(new_logger)
        @logger = new_logger
      end

      def verbose!
        logger.level = Logger::DEBUG
      end

      def quiet!
        logger.level = Logger::WARN
      end

      private

      def create_logger
        log = Logger.new($stderr)
        log.level = Logger::WARN
        log.formatter = proc do |severity, _datetime, _progname, msg|
          "#{severity}: #{msg}\n"
        end
        log
      end
    end
  end

  # Convenience methods at module level
  def self.logger
    Logging.logger
  end

  def self.logger=(new_logger)
    Logging.logger = new_logger
  end

  def self.verbose!
    Logging.verbose!
  end

  def self.quiet!
    Logging.quiet!
  end
end
