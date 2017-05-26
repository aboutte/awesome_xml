# frozen_string_literal: true

# A class that knows how to parse a point in time given a timestamp and a format string.
module AwesomeXML
  class DateTime
    include AwesomeXML::NativeType

  private

    def parse_value
      fail NoFormatProvided if options[:format].nil?
      ::DateTime.strptime(string, options[:format])
    end

    class NoFormatProvided < StandardError
      def initialize
        super('Please provide a format option to date_time nodes.')
      end
    end
  end
end
