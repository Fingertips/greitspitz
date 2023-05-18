require "../spec_helper"

describe Greitspitz::Instructions do
  it "parses an operation string" do
    instructions = Greitspitz::Instructions.new("fit:1920x1080,crop:4,quality:70,format:avif")
    instructions.format.should eq("avif")
    instructions.quality.should eq(70)
    instructions.transformations.should eq(
      {
        "fit"  => "1920x1080",
        "crop" => "4",
      }
    )
  end

  it "parses an operation string with a single transformation" do
    instructions = Greitspitz::Instructions.new("crop:480")
    instructions.format.should be_nil
    instructions.quality.should be_nil
    instructions.transformations.should eq(
      {
        "crop" => "480",
      }
    )
  end

  it "returns a content-type based on the format" do
    Greitspitz::Instructions::CONTENT_TYPES.each do |name, content_type|
      Greitspitz::Instructions.new("format:#{name}").content_type.should eq(content_type)
    end
  end

  it "does not return a content-type when format is not specified" do
    Greitspitz::Instructions.new("fit:4").content_type.should be_nil
  end

  it "allows changing the format after initialization" do
    instructions = Greitspitz::Instructions.new("crop:480")
    instructions.format.should be_nil
    instructions.format ||= "avif"
    instructions.format.should eq("avif")
    instructions.content_type.should eq("image/avif")
  end

  it "raises an exception for empty instructions" do
    expect_raises(ArgumentError, "Instructions can't be parsed, got: `'") do
      Greitspitz::Instructions.new("")
    end
  end

  it "raises an exception for garbage instructions" do
    expect_raises(ArgumentError, "Instructions can't be parsed, got: `garbage'") do
      Greitspitz::Instructions.new("garbage")
    end
  end

  it "raises an exception when setting a negative quality" do
    expect_raises(ArgumentError, "Quality may not be lower than 0") do
      Greitspitz::Instructions.new("quality:-1")
    end
  end

  it "raises an exception when setting quality higher than 100" do
    expect_raises(ArgumentError, "Quality may not be higher than 100") do
      Greitspitz::Instructions.new("quality:101")
    end
  end

  it "raises an exception when setting unknown format" do
    expect_raises(ArgumentError, "Unsupported format `unknown'") do
      Greitspitz::Instructions.new("format:unknown")
    end
  end
end
