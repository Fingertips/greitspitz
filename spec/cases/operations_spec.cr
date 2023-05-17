require "../spec_helper"

describe Greitspitz::Operations do
  it "parses an operation string" do
    operations = Greitspitz::Operations.parse("fit:1920x1080,crop:4,format:avif")
    operations.should eq(
      {
        "fit"    => "1920x1080",
        "crop"   => "4",
        "format" => "avif",
      }
    )
  end

  it "does not parse an empty operation string" do
    expect_raises(ArgumentError, "Operations formatting can't be parsed, got: `'") do
      Greitspitz::Operations.parse("")
    end
  end

  it "does not parse a garbage operation string" do
    expect_raises(ArgumentError, "Operations formatting can't be parsed, got: `garbage'") do
      Greitspitz::Operations.parse("garbage")
    end
  end
end
