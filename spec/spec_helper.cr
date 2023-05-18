require "spec"
require "uuid"
require "file_utils"

require "webmock"

require "../src/greitspitz"

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
