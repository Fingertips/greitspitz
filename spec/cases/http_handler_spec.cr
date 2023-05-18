require "../spec_helper"

describe Greitspitz::HttpHandler do
  it "serves an object from a bucket as a JPEG" do
    Spec.with_mocked_object_storage do
      session = Spec.create_session
      session.get("/avatars/w8cfGJVMmjzLdgZf/format:jpeg")
      session.response_status_code.should eq(200)
      session.response_content_type.should eq("image/jpeg")
    end
  end

  it "serves not found for objects missing in the bucket" do
    Spec.with_mocked_object_storage do
      session = Spec.create_session
      session.get("/avatars/1MiD6y6JPh8C4yGT/format:jpeg")
      session.response_status_code.should eq(404)
    end
  end

  it "serves not found for unsupported resources" do
    session = Spec.create_session
    session.get("/")
    session.response_status_code.should eq(404)
  end
end
