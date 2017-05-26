# frozen_string_literal: true

# A class that lets you parse a string according to the rules of a
# specified duration format chunk.
module AwesomeXML
  class Duration
    class ChunkParser
      attr_reader :duration_string_chunk, :format_chunk, :duration
      private :duration_string_chunk, :format_chunk

      # Parses a string given as `duration_string_chunk` according to the rules of the passed in
      # `format_chunk`. The latter being either a `AwesomeXML::Duration::Format::StaticChunk`
      # or a `AwesomeXML::Duration::Format::DynamicChunk`. Saves the resulting duration
      # in the attribute `duration`.
      def initialize(duration_string_chunk, format_chunk)
        @duration_string_chunk = duration_string_chunk
        @format_chunk = format_chunk
        parse
      end

    private

      def parse
        if format_chunk.dynamic?
          @duration = number.public_send(format_chunk.unit)
        else
          fail format_mismatch unless duration_string_chunk == format_chunk.to_s
          @duration = 0.seconds
        end
      end

      def number
        fail format_mismatch unless valid_number?
        duration_string_chunk.to_i
      end

      def valid_number?
        duration_string_chunk =~ /^[0-9]*$/
      end

      def format_mismatch
        FormatMismatch.new(duration_string_chunk, format_chunk.to_s)
      end

      class FormatMismatch < StandardError
        def initialize(timestamp, format_string)
          super("Duration string '#{timestamp}' does not conform to given format '#{format_string}'.")
        end
      end
    end
  end
end
