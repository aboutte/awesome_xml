# frozen_string_literal: true

# This module is shared by all native type classes of `AwesomeXML`. It defines the
# interface for types that the `AwesomeXML::NodeEvaluator` expects.
module AwesomeXML
  module NativeType
    def self.included(base)
      base.class_eval do
        base.extend(AwesomeXML::NativeType::ClassMethods)
      end
    end

    attr_reader :string, :options
    private :string, :options

    # Native type instances are initialized with a `Nokogiri::XML` object and an options hash.
    def initialize(string, options)
      @string = string
      @options = options
    end

    # This method returns the parsed value of the given node (obtained by calling `#text` on it) according
    # to the implementation of the private method `#parse_value` defined in every native type class.
    def evaluate
      @value ||= with_defaults { parse_value }
    end

    module ClassMethods
      def parsing_type?
        true
      end
    end

  private

    def with_defaults(&block)
      return options[:default] if string.nil?
      return options[:default_empty] if options.has_key?(:default_empty) && string.empty?
      return default_empty if string.empty?
      yield
    end

    def default_empty
      nil
    end
  end
end
