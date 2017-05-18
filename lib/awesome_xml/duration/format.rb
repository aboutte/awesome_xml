# frozen_string_literal: true

module AwesomeXML
  class Duration
    class Format
      attr_reader :format_string, :chunks
      private :format_string

      def initialize(format_string)
        @format_string = format_string
        @chunks = []
        compile
      end

    private

      def compile
        format_string.chars.each(&method(:process))
        @chunks = chunks&.compact
      end

      def process(character)
        case character
        when '{'
          chunks.append(DynamicChunk.new)
        when '}'
          chunks.append(nil)
        else
          if chunks.last.nil? 
            if chunks[-2].is_a?(DynamicChunk)
              chunks[-2].delimiter = character
            end
            chunks.tap(&:pop).append(StaticChunk.new)
          end

          chunks.last.format_chars.append(character)
        end
      end
    end
  end
end
