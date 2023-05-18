require "option_parser"

module Greitspitz
  # Parses command-line interface options and shows a usage banner.
  class OptionParser
    def self.parse(argv, context)
      ::OptionParser.parse(argv) do |parser|
        parser.banner = "Usage: greitspitz [options]"
        parser.separator ""
        parser.separator "Commands:"

        parser.on(
          "-l", "--log-level LOG_LEVEL",
          "Set log level to trace, debug, info, notice, warn, error, or fatal"
        ) do |log_level|
          context.log_level = log_level
        end

        parser.on("-h", "--help", "Show this help") do
          context.run = false
          puts parser
        end

        parser.invalid_option do |option|
          context.run = false
          puts "[!] Unsupported option: #{option}"
        end
      end
    end
  end
end
