require "spec"
require "uuid"
require "file_utils"

require "webmock"
Spec.before_each &->WebMock.reset

require "../src/greitspitz"
require "./support/http_session"

module Spec
  def self.root
    Path.new(Dir.current)
  end

  def self.tmp_path
    Spec.root.join("tmp")
  end

  def self.create_tmp
    FileUtils.mkdir_p(tmp_path)
  end

  def self.remove_tmp
    FileUtils.rm_rf(tmp_path)
  end

  def self.generate_tmp_filename
    tmp_path.join("#{UUID.random}")
  end

  def self.create_session
    Support::HttpSession.new
  end

  def self.with_mocked_object_storage(&block)
    Spec.with_environment(
      {
        "S3_ACCESS_KEY_ID"     => "eH1duJkVF42HywgT",
        "S3_SECRET_ACCESS_KEY" => "vCzJv67zbQPsduYv",
        "S3_HOST"              => "storage.example.com",
      }
    ) do
      File.open(root.join("spec/files/small.jpg"), "rb") do |file|
        WebMock.stub(
          :get, "https://storage.example.com/avatars/w8cfGJVMmjzLdgZf?"
        ).to_return(body_io: file)
        WebMock.stub(
          :get, "https://storage.example.com/avatars/1MiD6y6JPh8C4yGT?"
        ).to_return(status: 404, body_io: IO::Memory.new("<?xml><root></root>"))
        yield
      end
    end
  end

  # Change environment variables for the duration of the block to create a deterministic situation
  # for assertions.
  def self.with_environment(env : Hash(String, String | Nil), &block)
    before = env.keys.reduce({} of String => String | Nil) do |memo, name|
      memo[name] = ENV.fetch(name) { nil }
      memo
    end
    set_environment_variables(env)
    yield
  ensure
    set_environment_variables(before) if before
  end

  private def self.set_environment_variables(variables : Hash(String, String | Nil))
    variables.each do |name, value|
      ENV[name] = value
    end
  end
end

Spec.around_each do |example|
  Spec.create_tmp
  example.run
ensure
  Spec.remove_tmp
end
