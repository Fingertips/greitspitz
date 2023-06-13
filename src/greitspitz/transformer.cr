require "vips"

module Greitspitz
  # Applies a list of operations to transform a source image. Allows a format parameter to force
  # an output format other than JPEG.
  class Transformer
    getter format : String
    getter quality : Int32

    # We only support a subset of available formats in VIPS to reduce the attack surface on the
    # server and only serve image formats that make sense in the browser.
    FORMATS = {
      "avif" => ".avif",
      "jpeg" => ".jpg",
      "png"  => ".png",
    }

    def initialize(@input : IO, @instructions : Instructions)
      @format = FORMATS.fetch(@instructions.format) { ".jpg" }
      @quality = @instructions.quality || 90
    end

    def write(output : IO)
      image = Vips::Image.new_from_buffer(@input)
      image, _angle, _flip = image.autorot
      image = image.colourspace(Vips::Enums::Interpretation::Srgb)
      @instructions.transformations.each do |name, value|
        case name
        when "fit"
          image = apply_fit(image, value)
        when "crop"
          image = apply_crop(image, value)
        else
          raise ArgumentError.new("Unsupported operations `#{name}'")
        end
      end
      strip_metadata(image).write_to_target(output, format: format, Q: quality)
    end

    # Removes all metadata from the image.
    private def strip_metadata(image)
      image.mutate do |mutation|
        image.get_fields.each do |field|
          mutation.remove(field)
        end
      end
    end

    private def apply_fit(image, dimensions)
      width, height = self.class.parse_dimensions(dimensions)
      image.thumbnail_image(
        width, height: height,
        size: Vips::Enums::Size::Down
      )
    end

    private def apply_crop(image, dimensions)
      width, height = self.class.parse_dimensions(dimensions)
      image.thumbnail_image(
        width, height: height,
        crop: Vips::Enums::Interesting::Centre,
        size: Vips::Enums::Size::Down
      )
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
  end
end
