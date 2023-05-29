require "../spec_helper"

describe Greitspitz::OptionParser do
  it "configures a content when no options are passed" do
    context = Greitspitz::Context.new
    Greitspitz::OptionParser.parse([""], context)
    context.run?.should be_true
    context.log_level.should be_nil
  end

  it "allows changes to the bind address" do
    context = Greitspitz::Context.new
    Greitspitz::OptionParser.parse(["--bind-address", "tcp://0.0.0.0:888"], context)
    context.bind_address.should eq("tcp://0.0.0.0:888")
  end

  it "allows changes to the log-level" do
    context = Greitspitz::Context.new
    Greitspitz::OptionParser.parse(["--log-level", "fatal"], context)
    context.log_level.should eq("fatal")
  end
end
