require "option_parser"

module Greitspitz
  # Parses command-line interface options and shows a usage banner.
  class OptionParser
    def self.parse(argv, context)
      ::OptionParser.parse(argv) do |parser|
        parser.banner = "Usage: greitspitz [options]"
        parser.separator ""
        parser.separator "Commands:"

        parser.on("-h", "--help", "Show this help") do
          context.run = false
          puts parser
        end

        parser.on("-V", "--verbose", "Turn on verbose output.") do
          context.verbose = true
        end

        parser.invalid_option do |option|
          context.run = false
          puts "[!] Unsupported option: #{option}"
        end
      end
    end
  end
end
