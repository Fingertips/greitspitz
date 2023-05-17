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

  it "returns the storage access key id from the environment" do
    Spec.with_environment({"S3_ACCESS_KEY_ID" => "eH1duJkVF42HywgT"}) do
      Greitspitz::Context.new.storage_access_key_id.should eq("eH1duJkVF42HywgT")
    end
  end

  it "raises exception when storage access key id is not configured in the environment" do
    expect_raises(KeyError, "Missing ENV key: \"S3_ACCESS_KEY_ID\"") do
      Greitspitz::Context.new.storage_access_key_id
    end
  end

  it "returns the storage secret access key from the environment" do
    Spec.with_environment({"S3_SECRET_ACCESS_KEY" => "vCzJv67zbQPsduYv"}) do
      Greitspitz::Context.new.storage_secret_access_key.should eq("vCzJv67zbQPsduYv")
    end
  end

  it "raises exception when storage secret access key is not configured in the environment" do
    expect_raises(KeyError, "Missing ENV key: \"S3_SECRET_ACCESS_KEY\"") do
      Greitspitz::Context.new.storage_secret_access_key
    end
  end

  it "returns the storage host from the environment" do
    Spec.with_environment({"S3_HOST" => "storage.example.com"}) do
      Greitspitz::Context.new.storage_host.should eq("storage.example.com")
    end
  end

  it "raises exception when storage host is not configured in the environment" do
    expect_raises(KeyError, "Missing ENV key: \"S3_HOST\"") do
      Greitspitz::Context.new.storage_host
    end
  end

  it "formats the storage endpoint based on the storage host" do
    Spec.with_environment({"S3_HOST" => "storage.example.com"}) do
      Greitspitz::Context.new.storage_endpoint.should eq("https://storage.example.com")
    end
  end

  it "configures a storage client" do
    Spec.with_environment(
      {
        "S3_ACCESS_KEY_ID"     => "eH1duJkVF42HywgT",
        "S3_SECRET_ACCESS_KEY" => "vCzJv67zbQPsduYv",
        "S3_HOST"              => "storage.example.com",
      }
    ) do
      client = Greitspitz::Context.new.storage_client
      client.should be_a(Awscr::S3::Client)
    end
  end

  it "raises exception when building a storage client when environment variables are missing" do
    expect_raises(KeyError) do
      Greitspitz::Context.new.storage_client
    end
  end
end
