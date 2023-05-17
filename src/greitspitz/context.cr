module Greitspitz
  # Providers details about the environment and which switches were used when starting the server.
  class Context
    property? run
    property? verbose

    def initialize
      @run = true
      @verbose = false
    end
  end
end
