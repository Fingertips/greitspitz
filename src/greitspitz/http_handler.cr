require "http"
require "log"
require "uri"

module Greitspitz
  # Handles incoming HTTP requests.
  class HttpHandler
    include HTTP::Handler

    def initialize(@context : Context)
    end

    def call(context)
      parts = context.request.path.split("/").map { |part| URI.decode(part) }
      if parts.size > 2
        handle_request(context, parts[1], parts[2..-2].join("/"), parts[-1])
      else
        call_next(context)
      end
    end

    private def handle_request(context, bucket_name, key, input)
      context.response.headers["Connection"] = "keep-alive"
      instructions = Instructions.new(input)
      instructions.format ||= format(context.request.headers["Accept"])
      @context.storage_client.get_object(bucket_name, key) do |object|
        transformer = Transformer.new(object.body_io, instructions)
        context.response.content_type = instructions.content_type.not_nil!
        transformer.write(context.response.output)
      end
    rescue exception : XML::Error
      Log.error { exception.message }
      call_next(context)
    end

    private def format(accept : String | Nil)
      if accept && self.class.parse_accept(accept).includes?("image/avif")
        "avif"
      else
        "jpeg"
      end
    end

    def self.parse_accept(accept : String)
      accept.split(/,\s*/).map do |part|
        part.split(";", 2).first
      end
    end
  end
end
