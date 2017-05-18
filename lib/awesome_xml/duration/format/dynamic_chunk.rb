# frozen_string_literal: true

module AwesomeXML
  class Duration
    class Format
      class DynamicChunk
        UNITS = { 'D' => :days, 'H' => :hours, 'M' => :minutes, 'S' => :seconds}

        attr_accessor :format_chars, :delimiter

        def initialize
          @format_chars = []
        end

        def to_s
          [format_chars, delimiter].join
        end

        def dynamic?
          true
        end

        def unit
          fail InvalidDurationUnit.new(parsed_unit) unless valid_unit?
          @unit ||= UNITS[parsed_unit]
        end

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
