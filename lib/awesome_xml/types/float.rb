# frozen_string_literal: true

# A class that knows how to parse a Float from a String.
module AwesomeXML
  class Float
    include AwesomeXML::NativeType

  private

    def parse_value
      string.to_f
    end
  end
end
