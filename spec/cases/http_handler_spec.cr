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

  it "serves an object with a key that includes a slash" do
    Spec.with_mocked_object_storage do
      session = Spec.create_session
      session.get("/avatars/special/8awboFP4bFrbA8dZ/format:jpeg")
      session.response_status_code.should eq(200)
      session.response_content_type.should eq("image/jpeg")
    end
  end

  it "serves an object with a key that includes a slash" do
    Spec.with_mocked_object_storage do
      session = Spec.create_session
      session.get("/avatars/special%2F8awboFP4bFrbA8dZ/format:jpeg")
      session.response_status_code.should eq(200)
      session.response_content_type.should eq("image/jpeg")
    end
  end

  it "serves an object from a bucket as a resized AVIF" do
    Spec.with_mocked_object_storage do
      session = Spec.create_session
      session.get("/avatars/w8cfGJVMmjzLdgZf/fit:24,format:avif")
      session.response_status_code.should eq(200)
      session.response_content_type.should eq("image/avif")
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

  it "serves the image as JPEG when AVIF is not supported" do
    Spec.with_mocked_object_storage do
      session = Spec.create_session
      session.get(
        "/avatars/w8cfGJVMmjzLdgZf/quality:80",
        headers: {"Accept" => "*/*"}
      )
      session.response_status_code.should eq(200)
      session.response_content_type.should eq("image/jpeg")
    end
  end

  it "serves the image as JPEG when AVIF is supported, but JPEG is explicitly requested" do
    Spec.with_mocked_object_storage do
      session = Spec.create_session
      session.get(
        "/avatars/w8cfGJVMmjzLdgZf/quality:80,format:jpeg",
        headers: {"Accept" => "image/avif, */*"}
      )
      session.response_status_code.should eq(200)
      session.response_content_type.should eq("image/jpeg")
    end
  end

  it "serves the image as AVIF when it's supported" do
    Spec.with_mocked_object_storage do
      session = Spec.create_session
      session.get(
        "/avatars/w8cfGJVMmjzLdgZf/quality:80",
        headers: {"Accept" => "image/avif, */*"}
      )
      session.response_status_code.should eq(200)
      session.response_content_type.should eq("image/avif")
    end
  end
end
