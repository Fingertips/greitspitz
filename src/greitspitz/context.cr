require "awscr-s3"

module Greitspitz
  # Providers details about the environment and which switches were used when starting the server.
  class Context
    # Returns the log level for the process or Nil when it wasn't explicitly set.
    property log_level : String | Nil
    # Returns false when the CLI should not run any commands (eg. when printing usage info).
    property? run
    # Allows
    setter bind_address : String | Nil

    def initialize
      @run = true
      @log_level = nil
      self.bind_address = nil
    end

    def bind_address
      ENV.fetch("BIND_ADDR") { @bind_address }
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
