module Greitspitz
  # Configures the environment and starts the server or other commands.
  class Cli
    def initialize
      @context = Context.new
    end

    def run(argv)
      OptionParser.parse(argv, @context)
      run_command if @context.run?
    end

    private def run_command
      setup_logging
      start_http_server
    end

    private def setup_logging
      if @context.log_level
        ::Log.setup(@context.log_level.not_nil!)
      else
        ::Log.setup_from_env
      end
    end

    private def start_http_server
      HttpServer.new(@context).listen
    end
  end
end
