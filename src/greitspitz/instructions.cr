module Greitspitz
  # Parses operations, format, and quality instructions from a string.
  class Instructions
    CONTENT_TYPES = {
      "avif" => "image/avif",
      "jpeg" => "image/jpeg",
      "png"  => "image/png",
    }

    getter format : String | Nil
    getter quality : Int32 | Nil
    getter transformations : Hash(String, String)

    def initialize(input : String)
      @transformations = {} of String => String
      parse(input)
    end

    def content_type
      CONTENT_TYPES.fetch(format) { nil }
    end

    private def parse(input)
      input.split(",").each do |part|
        name, value = part.split(":", 2)
        add(name, value)
      end
    rescue IndexError
      raise ArgumentError.new("Instructions can't be parsed, got: `#{input}'")
    end

    private def add(name, value)
      case name
      when "format"
        @format = self.class.format(value)
      when "quality"
        @quality = self.class.quality(value)
      else
        @transformations[name] = value
      end
    end

    def self.format(format)
      return format if CONTENT_TYPES.has_key?(format)

      raise ArgumentError.new("Unsupported format `#{format}'")
    end

    def self.quality(quality)
      quality = quality.to_i
      raise ArgumentError.new("Quality may not be lower than 0") if quality < 0
      raise ArgumentError.new("Quality may not be higher than 100") if quality > 100
      quality
    end
  end
end
