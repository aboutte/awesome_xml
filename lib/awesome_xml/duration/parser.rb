# frozen_string_literal: true

module AwesomeXML
  class Duration
    class Parser
      attr_reader :timestamp, :format_string, :timestamp_chunks, :duration
      private :timestamp, :format_string, :timestamp_chunks

      def initialize(timestamp, format_string)
        @timestamp = timestamp
        @format_string = format_string
        @timestamp_chunks = []
        parse
      end

    private

      def parse
        chunk_timestamp
        @duration = timestamp_chunks.zip(format_chunks).sum { |timestamp_chunk, format_chunk|
          AwesomeXML::Duration::ChunkParser.new(timestamp_chunk, format_chunk).duration
        }.duration
      end

      def chunk_timestamp
        format_chunks.reduce(timestamp.chars) do |chopped_timestamp, format_chunk|
          if format_chunk.parse_length.zero?
            parse_length = chopped_timestamp.find_index(format_chunk.delimiter) || chopped_timestamp.length
          else
            parse_length = format_chunk.parse_length
          end
          timestamp_chunks.append(chopped_timestamp.first(parse_length).join)
          chopped_timestamp.drop(parse_length)
        end
      end

      def format_chunks
        @format_chunks ||= AwesomeXML::Duration::Format.new(format_string).chunks
      end

      def split_at_character(string, character)
        return string unless string.chars.include?(character)
        split_after(string, string.chars.find_index(character) - 1)
      end

      def split_after(string, after_position)
        [string.chars.first(after_position), string.chars.drop(after_position)].map(&:join)
      end
    end
  end
end
