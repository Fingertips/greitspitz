require "http"

module Greitspitz
  # Listens to HTTP requests and returns transformed images.
  class HttpServer
    def initialize(@context : Context)
    end

    def bind_address
      return "tcp://127.0.0.1:1090" unless @context.bind_address

      @context.bind_address.not_nil!
    end

    def listen
      http_server = HTTP::Server.new([
        HTTP::LogHandler.new(Log),
        Greitspitz::HttpHandler.new(@context),
      ])
      address = http_server.bind(bind_address)
      Log.info { "Listening on http://#{address}" }
      http_server.listen
    end
  end
end
