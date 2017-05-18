# frozen_string_literal: true

# A class that holds an array of characters and represents a dynamic
# component of a format string. Has a `unit`, a `parse_length` or a `delimiter`.
# See `AwesomeXML::Duration::Format` for more info.
module AwesomeXML
  class Duration
    class Format
      class DynamicChunk
        UNITS = { 'D' => :days, 'H' => :hours, 'M' => :minutes, 'S' => :seconds}

        attr_accessor :format_chars, :delimiter

        def initialize
          @format_chars = []
        end

        # Returns the defining characters joint into a string.
        def to_s
          [format_chars, delimiter].join
        end

        # Counterpart of the same method of `AwesomeXML::Duration::Format::DynamicChunk`.
        # Used to differentiate between instances of these two classes.
        def dynamic?
          true
        end

        # Takes the first character of `format_chars` and interprets as a duration unit.
        def unit
          fail InvalidDurationUnit.new(parsed_unit) unless valid_unit?
          @unit ||= UNITS[parsed_unit]
        end

        # Takes the characters following the first character of `format_chars` and interprets
        # them as an integer representing the number of characters to parse when given to the
        # `AweseomXML::Duration::ChunkParser` together with a piece of duration string.
        # When the `format_chars` only contain a single character, this will be 0.
        def parse_length
          fail InvalidParseLength.new(parsed_parse_length) unless valid_parse_length?
          @parse_length ||= parsed_parse_length.to_i
        end

      private

        def valid_unit?
          %w(D H M S).include?(parsed_unit)
        end

        def parsed_unit
          format_chars[0]
        end

        def valid_parse_length?
          parsed_parse_length =~ /^[0-9]*$/ || parsed_parse_length.nil?
        end

        def parsed_parse_length
          @parsed_parse_length ||= format_chars.drop(1).join
        end

        class InvalidDurationUnit < StandardError
          def initialize(parsed_unit)
            super("Parsed unknown duration unit: '#{parsed_unit}'. Please choose from [D, H, M, S].")
          end
        end

        class InvalidParseLength < StandardError
          def initialize(parsed_parse_length)
            super("Couldn't parse '#{parsed_parse_length}' to an integer.")
          end
        end
      end
    end
  end
end
