# frozen_string_literal: true

module AwesomeXML
  class Duration
    class Format
      class StaticChunk
        attr_accessor :format_chars

        def initialize
          @format_chars = []
        end

        def to_s
          format_chars.join
        end

        def parse_length
          format_chars.length
        end

        def dynamic?
          false
        end
      end
    end
  end
end
