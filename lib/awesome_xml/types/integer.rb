# frozen_string_literal: true

# A class that knows how to parse an Integer from a String.
module AwesomeXML
  class Integer
    include AwesomeXML::NativeType

  private

    def parse_value
      string.to_i
    end
  end
end
