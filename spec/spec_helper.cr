require "spec"
require "uuid"
require "file_utils"

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
end

Spec.around_each do |example|
  Spec.create_tmp
  example.run
ensure
  Spec.remove_tmp
end
