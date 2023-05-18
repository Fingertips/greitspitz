require "vips"

module Greitspitz
  # Applies a list of operations to transform a source image. Allows a format parameter to force
  # an output format other than JPEG.
  class Transformer
    # We only support a subset of available formats in VIPS to reduce the attack surface on the
    # server and only serve image formats that make sense in the browser.
    FORMATS = {
      "avif" => ".avif",
      "jpeg" => ".jpg",
      "png"  => ".png",
    }

    CONTENT_TYPES = {
      "avif" => "image/avif",
      "jpeg" => "image/jpeg",
      "png"  => "image/png",
    }

    def initialize(@input : IO, @operations : Hash(String, String))
      raise ArgumentError.new("Operations may not be empty") if @operations.empty?
    end

    def content_type
      content_type_from_operations || "image/jpeg"
    end

    def write(output : IO)
      image = Vips::Image.new_from_buffer(@input)
      format = ".jpg"
      @operations.each do |name, value|
        case name
        when "fit"
          width, height = self.class.parse_dimensions(value)
          image = image.thumbnail_image(
            width, height: height,
            size: Vips::Enums::Size::Down
          )
        when "crop"
          width, height = self.class.parse_dimensions(value)
          image = image.thumbnail_image(
            width, height: height,
            crop: Vips::Enums::Interesting::Centre,
            size: Vips::Enums::Size::Down
          )
        when "format"
          format = self.class.format(value)
        else
          raise ArgumentError.new("Unsupported operations `#{name}'")
        end
      end
      image.write_to_target(output, format: format)
    end

    def self.parse_dimensions(value)
      dimensions = value.split("x").map { |dimension| dimension.to_i }
      case dimensions.size
      when 2
        dimensions
      when 1
        [dimensions[0], dimensions[0]]
      else
        raise ArgumentError.new(
          "Dimensions should either be in the form 'MxN' or 'N': got: `#{value}'"
        )
      end
    end

    def self.format(format)
      FORMATS.fetch(format) do
        raise ArgumentError.new("Unsupported format `#{format}'")
      end
    end

    private def content_type_from_operations
      @operations.each do |name, value|
        next unless name == "format"

        return CONTENT_TYPES[value]
      end
      nil
    end
  end
end
