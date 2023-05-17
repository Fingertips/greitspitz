module Greitspitz
  class Cli
    def initialize
      @context = Context.new
    end

    def run(argv)
      OptionParser.parse(argv, @context)
    end
  end
end
