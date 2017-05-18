# frozen_string_literal: true

# A collection of node building methods that will be available as class methods
# on classes that include `AwesomeXML::Root` or `AwesomeXML::Child`.
module AwesomeXML
  module BuilderMethods
    SIMPLE_TYPES = [:text, :integer, :float, :duration].freeze

    # Defines a method on your class returning a constant.
    def constant_node(name, value, options = {})
      define_method(name.to_sym) do
        value
      end
      register(name) unless options[:private]
    end

    # Does not actually define a method, but registers the node name
    # in the `@nodes` attribute.
    def method_node(name)
      register(name)
    end

    # Defines aliases for all possible `.simple_node` types.
    SIMPLE_TYPES.each do |type|
      define_method("#{type}_node") do |*args, &block|
        simple_node(type, *args, &block)
      end
    end

    # Defines a method on your class returning a value specified by type and
    # `XPath` to a node in the XML document stored in the `data` attribute.
    def simple_node(type, name, xpath, options = {}, &block)
      fail UnknownNodeType.new(type) unless SIMPLE_TYPES.include?(type)
      define_method(name.to_sym) do
        evaluate_node(xpath, type, options[:format], &block)
      end
      register(name) unless options[:private]
    end

    # Defines aliases for all possible `.simple_array_node` types.
    SIMPLE_TYPES.each do |type|
      define_method("#{type}_array_node") do |*args, &block|
        simple_array_node(type, *args, &block)
      end
    end

    # Defines a method on your class returning an array of values specified by type and
    # `XPath` to several nodes in the XML document stored in the `data` attribute.
    def simple_array_node(type, name, xpath, options = {}, &block)
      fail UnknownNodeType.new(type) unless SIMPLE_TYPES.include?(type)
      define_method(name.to_sym) do
        evaluate_nodes(xpath, type, options[:format], &block)
      end
      register(name) unless options[:private]
    end

    # Defines a method on your class returning a `Hash` containing names and values of nodes
    # defined in another class, which you can pass in as an argument to this method.
    def child_node(name, node_class_name, xpath, options = {}, &block)
      define_method(name.to_sym) do
        evaluate_child_node(node_class_name, find_node(xpath), &block)
      end
      register(name) unless options[:private]
    end

    # Defines a method on your class returning an array of `Hash`es, each containing names and
    # values of nodes defined in another class, which you can pass in as an argument to this method.
    def child_array_node(name, node_class_name, xpath, options = {}, &block)
      define_method(name.to_sym) do
        evaluate_child_nodes(node_class_name, xpath, &block)
      end
      register(name) unless options[:private]
    end

    # Returns an array of symbols containing all method names defined by node builder methods
    # in your class. Does not list nodes built with option `:private`.
    def nodes
      @nodes ||= []
    end

    # Utility method that parses a string according to the type it's given. Has to be public
    # because instance methods defined on your class by node builder methods need to use it.
    # Not really intended to be used publically.
    def parse_type(string, type, format)
      return unless string.present?
      case type
      when :text
        string
      when :integer
        string.to_i
      when :float
        string.to_f
      when :duration
        AwesomeXML::Duration::Parser.new(string, format).duration
      end
    end

  private

    def register(node_name)
      @nodes ||= []
      @nodes << node_name.to_sym
    end

    class UnknownNodeType < StandardError
      def initialize(type)
        super("Cannot create node with unknown node type '#{type}'.")
      end
    end
  end
end
