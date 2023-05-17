require "../spec_helper"

describe Greitspitz::Cli do
  it "runs" do
    cli = Greitspitz::Cli.new
    cli.run([""])
  end
end
