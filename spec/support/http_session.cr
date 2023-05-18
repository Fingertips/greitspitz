module Support
  # Keeps request and response objects around so you can interact with the HttpHandler without
  # having to deal with HTTP details.
  class HttpSession
    @request : HTTP::Request | Nil
    @response : HTTP::Server::Response | Nil
    @response_io : IO::Memory | Nil

    def initialize
      @context = Greitspitz::Context.new
      @http_handler = Greitspitz::HttpHandler.new(@context)
    end

    def request
      @request.not_nil!
    end

    def response
      @response.not_nil!
    end

    def response_status_code
      response.status.to_i
    end

    def response_content_type
      response.headers["Content-Type"]
    end

    def response_io
      @response_io.not_nil!
    end

    def response_body
      response_io.rewind
      response_io.gets_to_end
    end

    def get(resource : String)
      @response_io = IO::Memory.new
      @request = HTTP::Request.new("GET", resource)
      @response = HTTP::Server::Response.new(response_io)
      @http_handler.call(HTTP::Server::Context.new(request, response))
    end
  end
end
