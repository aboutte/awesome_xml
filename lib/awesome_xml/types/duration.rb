# frozen_string_literal: true

# A class that knows how to parse a duration given a duration string and a format string.
module AwesomeXML
  class Duration
    include AwesomeXML::NativeType

  private

    def parse_value
      fail NoFormatProvided if options[:format].nil?
      string_chunks.zip(format_chunks).map do |string_chunk, format_chunk|
        AwesomeXML::Duration::ChunkParser.new(string_chunk, format_chunk).duration
      end.reduce(:+) || 0.seconds
    end

    def string_chunks
      @string_chunks ||= chunk_string
    end

    def chunk_string
      result = []
      format_chunks.reduce(string.chars) do |chopped_string, format_chunk|
        if format_chunk.parse_length.zero?
          parse_length = chopped_string.find_index(format_chunk.delimiter) || chopped_string.length
        else
          parse_length = format_chunk.parse_length
        end
        result.append(chopped_string.first(parse_length).join)
        chopped_string.drop(parse_length)
      end
      result
    end

    def format_chunks
      @format_chunks ||= AwesomeXML::Duration::Format.new(options[:format]).chunks
    end

    def split_at_character(string, character)
      return string unless string.chars.include?(character)
      split_after(string, string.chars.find_index(character) - 1)
    end

    def split_after(string, after_position)
      [string.chars.first(after_position), string.chars.drop(after_position)].map(&:join)
    end

    class NoFormatProvided < StandardError
      def initialize
        super('Please provide a format option to duration nodes.')
      end
    end
  end
end