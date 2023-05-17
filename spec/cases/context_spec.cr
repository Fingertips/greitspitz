require "../spec_helper"

describe Greitspitz::Context do
  it "runs by default" do
    Greitspitz::Context.new.run?.should be_true
  end

  it "can be configured to not run" do
    context = Greitspitz::Context.new
    context.run = false
    context.run?.should be_false
  end

  it "not verbose by default" do
    Greitspitz::Context.new.verbose?.should be_false
  end

  it "can be configured to be verbose" do
    context = Greitspitz::Context.new
    context.verbose = true
    context.verbose?.should be_true
  end
end
