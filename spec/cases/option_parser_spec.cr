require "../spec_helper"

describe Greitspitz::OptionParser do
  it "configures a content when no options are passed" do
    context = Greitspitz::Context.new
    Greitspitz::OptionParser.parse([""], context)
    context.run?.should be_true
    context.verbose?.should be_false
  end

  it "allows verbose logging" do
    context = Greitspitz::Context.new
    Greitspitz::OptionParser.parse(["--verbose"], context)
    context.run?.should be_true
    context.verbose?.should be_true
  end
end
