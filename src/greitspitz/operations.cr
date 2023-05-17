module Greitspitz
  # Parses operations and format parameters from a string.
  class Operations
    def self.parse(input : String)
      input.split(",").reduce({} of String => String) do |operations, part|
        name, value = part.split(":", 2)
        operations[name] = value
        operations
      end
    rescue IndexError
      raise ArgumentError.new("Operations formatting can't be parsed, got: `#{input}'")
    end
  end
end
