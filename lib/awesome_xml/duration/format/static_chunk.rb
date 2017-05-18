# frozen_string_literal: true

# A class that holds an array of characters and represents a static
# component of a format string. See `AwesomeXML::Duration::Format` for more info.
module AwesomeXML
  class Duration
    class Format
      class StaticChunk
        attr_accessor :format_chars

        def initialize
          @format_chars = []
        end

        # Returns the defining characters joint into a string.
        def to_s
          format_chars.join
        end

        # Returns the number of the defining characters.
        def parse_length
          format_chars.length
        end

        # Counterpart of the same method of `AwesomeXML::Duration::Format::DynamicChunk`.
        # Used to differentiate between instances of these two classes.
        def dynamic?
          false
        end
      end
    end
  end
end
