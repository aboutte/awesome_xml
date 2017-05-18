# frozen_string_literal: true

module AwesomeXML
  class Duration
    UNITS = %i(days hours minutes seconds).freeze
    UNIT_MULTIPLIERS = { days: 86_400, hours: 3_600, minutes: 60, seconds: 1 }.freeze

    attr_reader *UNITS

    def initialize(attrs = {})
      raise InvalidInitializeArguments.new(attrs) unless attrs.is_a?(Hash)
      attrs.each { |unit, value| add_value(value, unit) }
    end

    def duration
      UNITS.sum { |unit| (public_send(unit) || 0) * UNIT_MULTIPLIERS[unit] }
    end

    def +(duration)
      UNITS.each { |unit| add_value(duration.public_send(unit), unit) if duration.public_send(unit) }
      self
    end

  private

    def add_value(value, unit)
      return if value.nil?
      fail UnknownTimeUnit.new(unit) unless UNITS.include?(unit)
      fail DoubleValueAssignment.new(unit) unless public_send(unit).nil?
      fail ValueIsNotNumeric.new(value, unit) unless value.is_a?(Numeric)
      instance_variable_set("@#{unit}", value)
    end

    class InvalidInitializeArguments < StandardError
      def initialize(args)
        super("Invalid arguments passed to `#initialize`: '#{args}'")
      end
    end

    class UnknownTimeUnit < StandardError
      def initialize(unit)
        super("Don't know what time unit '#{unit}' is.")
      end
    end

    class DoubleValueAssignment < StandardError
      def initialize(unit)
        super("Value for unit '#{unit}' is already assigned.")
      end
    end

    class ValueIsNotNumeric < StandardError
      def initialize(value, unit)
        super("Value #{value} for unit '#{unit}' is not numeric.")
      end
    end
  end
end