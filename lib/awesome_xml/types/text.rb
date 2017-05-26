# frozen_string_literal: true

# A class that knows how to parse a String from a String. Shockingly, it doesn't do much.
module AwesomeXML
  class Text
    include AwesomeXML::NativeType

  private

    def parse_value
      string
    end

    def default_empty
      ''
    end
  end
end
