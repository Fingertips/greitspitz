require "http"

module Greitspitz
  # Listens to HTTP requests and returns transformed images.
  class HttpServer
    def initialize(@context : Context)
    end

    def listen
      http_server = HTTP::Server.new([
        HTTP::LogHandler.new,
        Greitspitz::HttpHandler.new(@context),
      ])
      address = http_server.bind_tcp 1090
      Log.info { "Listening on http://#{address}" }
      http_server.listen
    end
  end
end
