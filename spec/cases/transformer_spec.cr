require "../spec_helper"

describe Greitspitz::Transformer do
  it "scales an image to fit within a bounding box" do
    image = Spec.transform_image("fit:40x40")
    image.width.should eq(40)
    image.height.should eq(40)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "scales a landscape image to fit within the bounding box" do
    image = Spec.transform_image(
      "fit:40x60",
      IO::Memory.new(Vips::Image.gaussnoise(400, 300).jpegsave_buffer)
    )
    image.width.should eq(40)
    image.height.should eq(30)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "scales a portrait image to fit within the bounding box" do
    image = Spec.transform_image(
      "fit:40x60",
      IO::Memory.new(Vips::Image.gaussnoise(312, 669).jpegsave_buffer)
    )
    image.width.should eq(28)
    image.height.should eq(60)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "scales an image to make its longest side at most a certain value" do
    image = Spec.transform_image("fit:4")
    image.width.should eq(4)
    image.height.should eq(4)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "does not fit up when image is smaller than bounding box" do
    image = Spec.transform_image(
      "fit:600x400",
      IO::Memory.new(Vips::Image.gaussnoise(400, 300).jpegsave_buffer)
    )
    image.width.should eq(400)
    image.height.should eq(300)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "does not scale an image with a bad fit value" do
    expect_raises(
      ArgumentError,
      "Dimensions should either be in the form 'MxN' or 'N': got: `80x80x80'"
    ) do
      Spec.transform_image("fit:80x80x80")
    end
  end

  it "crops an image to fit within a bounding box" do
    image = Spec.transform_image("crop:2x4")
    image.width.should eq(2)
    image.height.should eq(4)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "crops a landscape image to fit within the bounding box" do
    image = Spec.transform_image(
      "crop:16x4",
      IO::Memory.new(Vips::Image.gaussnoise(400, 300).jpegsave_buffer)
    )
    image.width.should eq(16)
    image.height.should eq(4)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "crops a portrait image to fit within the bounding box" do
    image = Spec.transform_image(
      "crop:2x4",
      IO::Memory.new(Vips::Image.gaussnoise(312, 669).jpegsave_buffer)
    )
    image.width.should eq(2)
    image.height.should eq(4)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "does not drop up when image is smaller than bounding box" do
    image = Spec.transform_image(
      "crop:600x400",
      IO::Memory.new(Vips::Image.gaussnoise(400, 300).jpegsave_buffer)
    )
    image.width.should eq(400)
    image.height.should eq(300)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "formats the output as AVIF" do
    image = Spec.transform_image("format:avif")
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/avif")
  end

  it "formats the output as JPEG" do
    image = Spec.transform_image("format:jpeg")
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "formats the output as PNG" do
    image = Spec.transform_image("format:png")
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/png")
  end

  it "writes the output as sRGB without an ICC profile" do
    image = Spec.transform_image("format:jpeg")
    image.get_typeof("icc-profile-data").should eq(0)
  end

  it "sets the quality of the resulting JPEG image" do
    image = Spec.transform_image("quality:90")
    file_size = File.size(image.filename)

    image = Spec.transform_image("quality:50")
    File.size(image.filename).should be < file_size
  end

  it "sets the quality of the resulting AVIF image" do
    image = Spec.transform_image("quality:90,format:avif")
    file_size = File.size(image.filename)

    image = Spec.transform_image("quality:50,format:avif")
    File.size(image.filename).should be < file_size
  end

  it "ignores the quality of the resulting PNG image" do
    image = Spec.transform_image("quality:90,format:png")
    file_size = File.size(image.filename)

    image = Spec.transform_image("quality:50,format:png")
    File.size(image.filename).should eq(file_size)
  end

  it "strips metadata from an image" do
    image = Vips::Image.black(4, 4)
    image = image.mutate do |mutation|
      mutation.set(Vips::GValue::GString, "exif-ifd0-Model", "Canon EOS M100")
    end
    transformer = Greitspitz::Transformer.new(
      IO::Memory.new(image.jpegsave_buffer),
      Greitspitz::Instructions.new("quality:30")
    )
    output = IO::Memory.new
    transformer.write(output)
    output.rewind
    image = Vips::Image.new_from_buffer(output)
    image.get_fields.includes?("exif-ifd0-Model").should be_false
  end

  it "transforms a PNG" do
    image = Spec.transform_image("fit:40x40", extension: ".png")
    image.width.should eq(40)
    image.height.should eq(40)
    content_type = `file --mime-type #{image.filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end
end
