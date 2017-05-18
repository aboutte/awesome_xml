# frozen_string_literal: true

# A class that lets you parse a duration string according to a user defined format.
module AwesomeXML
  class Duration
    class Parser
      attr_reader :duration_string, :format_string, :duration_string_chunks, :duration
      private :duration_string, :format_string, :duration_string_chunks

      # Returns an `ActiveSupport::Duration` instance with a `duration` attribute populated with the
      # given `duration_string` parsed according to the format specified in `format_string`.
      # The syntax for the format string is best explained with an example:
      # Say your `duration_string` is of the form `1234` with the first two digits meaning minutes
      # and the last two meaning seconds. Your `format_string` should equal `'{M2}{S2}'`, then.
      # The first character of a section inside curly bracktes symbolizes the duration unit
      # according to {'D' => :days, 'H' => :hours, 'M' => 'minutes', 'S' => :seconds}. The second
      # character is the number of digits that should be parsed.
      # If the number of digits varies (e.g. valid duration string would be `12m34`, but also `1m2`),
      # specify no number of digits, meaning a format string of `'{M}m{s}'`. The parser will take all
      # digits until the next character specified in the format string or the end of the duration string.
      def initialize(duration_string, format_string)
        @duration_string = duration_string
        @format_string = format_string
        @duration_string_chunks = []
        parse
      end

    private

      def parse
        chunk_duration_string
        @duration = duration_string_chunks.zip(format_chunks).sum { |duration_string_chunk, format_chunk|
          AwesomeXML::Duration::ChunkParser.new(duration_string_chunk, format_chunk).duration
        }.duration
      end

      def chunk_duration_string
        format_chunks.reduce(duration_string.chars) do |chopped_duration_string, format_chunk|
          if format_chunk.parse_length.zero?
            parse_length = chopped_duration_string.find_index(format_chunk.delimiter) || chopped_duration_string.length
          else
            parse_length = format_chunk.parse_length
          end
          duration_string_chunks.append(chopped_duration_string.first(parse_length).join)
          chopped_duration_string.drop(parse_length)
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
