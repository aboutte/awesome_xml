# frozen_string_literal: true

module AwesomeXML
  class Duration
    class ChunkParser
      attr_reader :timestamp_chunk, :format_chunk, :duration
      private :timestamp_chunk, :format_chunk

      def initialize(timestamp_chunk, format_chunk)
        @timestamp_chunk = timestamp_chunk
        @format_chunk = format_chunk
        parse
      end

    private

      def parse
        if format_chunk.dynamic?
          @duration = AwesomeXML::Duration.new(format_chunk.unit => number)
        else
          fail format_mismatch unless timestamp_chunk == format_chunk.to_s
          @duration = AwesomeXML::Duration.new
        end
      end

      def number
        fail format_mismatch unless valid_number?
        timestamp_chunk.to_i
      end

      def valid_number?
        timestamp_chunk =~ /^[0-9]*$/
      end

      def format_mismatch
        FormatMismatch.new(timestamp_chunk, format_chunk.to_s)
      end

      class FormatMismatch < StandardError
        def initialize(timestamp, format_string)
          super("Timestamp '#{timestamp}' does not conform to given format '#{format_string}'.")
        end
      end
    end
  end
end
