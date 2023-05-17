require "awscr-s3"

module Greitspitz
  # Providers details about the environment and which switches were used when starting the server.
  class Context
    property? run
    property? verbose

    def initialize
      @run = true
      @verbose = false
    end

    def storage_access_key_id
      ENV["S3_ACCESS_KEY_ID"]
    end

    def storage_secret_access_key
      ENV["S3_SECRET_ACCESS_KEY"]
    end

    def storage_host
      ENV["S3_HOST"]
    end

    def storage_endpoint
      "https://#{storage_host}"
    end

    def storage_client
      Awscr::S3::Client.new(
        "us-east-1", storage_access_key_id, storage_secret_access_key, endpoint: storage_endpoint
      )
    end
  end
end
