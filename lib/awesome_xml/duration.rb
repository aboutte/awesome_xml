# frozen_string_literal: true

# A class that represents a parsed duration. Stores a value for each of
# `[:days, :hours, :minutes, :seconds]`. Will throw an exception if you try and
# assign a value to a unit attribute that has already a value assigned to it.
module AwesomeXML
  class Duration
    UNITS = %i(days hours minutes seconds).freeze
    UNIT_MULTIPLIERS = { days: 86_400, hours: 3_600, minutes: 60, seconds: 1 }.freeze

    attr_reader *UNITS

    # Returns an instance of `AweseomeXML::Duration`. You can pass in starting values
    # for all units or some or none.
    def initialize(attrs = {})
      raise InvalidInitializeArguments.new(attrs) unless attrs.is_a?(Hash)
      attrs.each { |unit, value| add_value(value, unit) }
    end

    # Returns an `ActiveSupport::Duration` matching the summed duration of all values
    # in the unit attributes.
    def duration
      UNITS.sum { |unit| (public_send(unit) || 0) * UNIT_MULTIPLIERS[unit] }
    end

    # Adds two `AwesomeXML::Duration`s together. Note that it will throw an exception
    # if there are unit attributes that have a value assigned in both objects.
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