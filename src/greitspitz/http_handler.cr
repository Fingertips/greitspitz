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
      if context.request.path =~ /^\/([^\/]+)\/([^\/]+)\/([^\/]+)$/
        handle_request(context, URI.decode($1), URI.decode($2), URI.decode($3))
      else
        call_next(context)
      end
    end

    private def handle_request(context, bucket_name, key, operations)
      context.response.headers["Connection"] = "keep-alive"
      operations = Operations.parse(operations)
      Log.debug { "GET: s3:/#{bucket_name}/#{key} (#{operations})" }
      @context.storage_client.get_object(bucket_name, key) do |object|
        transformer = Transformer.new(object.body_io, operations)
        context.response.content_type = transformer.content_type
        transformer.write(context.response.output)
      end
    rescue exception : XML::Error
      Log.error { exception.message }
      call_next(context)
    end
  end
end
