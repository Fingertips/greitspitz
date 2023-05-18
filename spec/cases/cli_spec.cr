require "../spec_helper"

# NOTE: There are functional tests for the server because a lot of this is glue code that
# eventually starts an infinitely waiting HTTP server.
describe Greitspitz::Cli do
  it "initializes" do
    Greitspitz::Cli.new
  end
end
