require "../spec_helper"

describe Greitspitz::Transformer do
  it "raises an exception about empty operation" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        expect_raises(
          ArgumentError,
          "Operations may not be empty"
        ) do
          Greitspitz::Transformer.new(input, {} of String => String).write(output)
        end
      end
    end
    File.size(temporary_filename).should eq(0)
  end

  it "scales an image to fit within a bounding box" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        Greitspitz::Transformer.new(
          input,
          {"fit" => "40x40"}
        ).write(output)
      end
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(40)
    image.height.should eq(40)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "scales a landscape image to fit within the bounding box" do
    temporary_filename = Spec.generate_tmp_filename
    input = IO::Memory.new(Vips::Image.gaussnoise(400, 300).jpegsave_buffer)
    File.open(temporary_filename, "wb") do |output|
      Greitspitz::Transformer.new(
        input,
        {"fit" => "40x60"}
      ).write(output)
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(40)
    image.height.should eq(30)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "scales a portrait image to fit within the bounding box" do
    temporary_filename = Spec.generate_tmp_filename
    input = IO::Memory.new(Vips::Image.gaussnoise(312, 669).jpegsave_buffer)
    File.open(temporary_filename, "wb") do |output|
      Greitspitz::Transformer.new(
        input,
        {"fit" => "40x60"}
      ).write(output)
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(28)
    image.height.should eq(60)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "scales an image to make its longest side at most a certain value" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        Greitspitz::Transformer.new(
          input,
          {"fit" => "4"}
        ).write(output)
      end
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(4)
    image.height.should eq(4)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "does not fit up when image is smaller than bounding box" do
    temporary_filename = Spec.generate_tmp_filename
    input = IO::Memory.new(Vips::Image.gaussnoise(400, 300).jpegsave_buffer)
    File.open(temporary_filename, "wb") do |output|
      Greitspitz::Transformer.new(
        input,
        {"fit" => "600x400"}
      ).write(output)
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(400)
    image.height.should eq(300)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "does not scale an image with a bad fit value" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        expect_raises(
          ArgumentError,
          "Dimensions should either be in the form 'MxN' or 'N': got: `80x80x80'"
        ) do
          Greitspitz::Transformer.new(
            input,
            {"fit" => "80x80x80"}
          ).write(output)
        end
      end
    end
  end

  it "crops an image to fit within a bounding box" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        Greitspitz::Transformer.new(
          input,
          {"crop" => "2x4"}
        ).write(output)
      end
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(2)
    image.height.should eq(4)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "crops a landscape image to fit within the bounding box" do
    temporary_filename = Spec.generate_tmp_filename
    input = IO::Memory.new(Vips::Image.gaussnoise(400, 300).jpegsave_buffer)
    File.open(temporary_filename, "wb") do |output|
      Greitspitz::Transformer.new(
        input,
        {"crop" => "16x4"}
      ).write(output)
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(16)
    image.height.should eq(4)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "crops a portrait image to fit within the bounding box" do
    temporary_filename = Spec.generate_tmp_filename
    input = IO::Memory.new(Vips::Image.gaussnoise(312, 669).jpegsave_buffer)
    File.open(temporary_filename, "wb") do |output|
      Greitspitz::Transformer.new(
        input,
        {"crop" => "2x4"}
      ).write(output)
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(2)
    image.height.should eq(4)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "does not drop up when image is smaller than bounding box" do
    temporary_filename = Spec.generate_tmp_filename
    input = IO::Memory.new(Vips::Image.gaussnoise(400, 300).jpegsave_buffer)
    File.open(temporary_filename, "wb") do |output|
      Greitspitz::Transformer.new(
        input,
        {"crop" => "600x400"}
      ).write(output)
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(400)
    image.height.should eq(300)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "formats the output as AVIF" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        Greitspitz::Transformer.new(
          input,
          {
            "fit"    => "12x4",
            "format" => "avif",
          }
        ).write(output)
      end
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(4)
    image.height.should eq(4)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/avif")
  end

  it "formats the output as JPEG" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        Greitspitz::Transformer.new(
          input,
          {
            "fit"    => "12x4",
            "format" => "jpeg",
          }
        ).write(output)
      end
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(4)
    image.height.should eq(4)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/jpeg")
  end

  it "formats the output as PNG" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        Greitspitz::Transformer.new(
          input,
          {
            "fit"    => "12x4",
            "format" => "png",
          }
        ).write(output)
      end
    end
    image = Vips::Image.new_from_file(temporary_filename.to_s)
    image.width.should eq(4)
    image.height.should eq(4)
    content_type = `file --mime-type #{temporary_filename}`.split(":").last.strip
    content_type.should eq("image/png")
  end

  it "does not format the output as an unknown format" do
    temporary_filename = Spec.generate_tmp_filename
    File.open(Spec.root.join("spec/files/small.jpg"), "rb") do |input|
      File.open(temporary_filename, "wb") do |output|
        expect_raises(
          ArgumentError,
          "Unsupported format `unknown'"
        ) do
          Greitspitz::Transformer.new(
            input,
            {"format" => "unknown"}
          ).write(output)
        end
      end
    end
  end
end
