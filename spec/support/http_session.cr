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
      perform_get(resource, headers: nil)
    end

    def get(resource : String, headers : Hash(String, String))
      perform_get(resource, headers: headers)
    end

    private def perform_get(resource, headers : Hash(String, String) | Nil)
      http_headers = HTTP::Headers.new
      headers.each { |name, value| http_headers.add(name, value) } if headers
      @response_io = IO::Memory.new
      @request = HTTP::Request.new("GET", resource, headers: http_headers)
      @response = HTTP::Server::Response.new(response_io)
      @http_handler.call(HTTP::Server::Context.new(request, response))
    end
  end
end
