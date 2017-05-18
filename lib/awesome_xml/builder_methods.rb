# frozen_string_literal: true

module AwesomeXML
  module BuilderMethods
    SIMPLE_TYPES = [:text, :integer, :float, :duration].freeze

    def constant_node(name, value, options = {})
      define_method(name.to_sym) do
        value
      end
      register(name) unless options[:private]
    end

    def method_node(name)
      register(name)
    end

    SIMPLE_TYPES.each do |type|
      define_method("#{type}_node") do |*args, &block|
        simple_node(type, *args, &block)
      end
    end

    def simple_node(type, name, xpath, options = {}, &block)
      fail UnknownNodeType.new(type) unless SIMPLE_TYPES.include?(type)
      define_method(name.to_sym) do
        evaluate_node(xpath, type, options[:format], &block)
      end
      register(name) unless options[:private]
    end

    SIMPLE_TYPES.each do |type|
      define_method("#{type}_array_node") do |*args, &block|
        simple_array_node(type, *args, &block)
      end
    end

    def simple_array_node(type, name, xpath, options = {}, &block)
      fail UnknownNodeType.new(type) unless SIMPLE_TYPES.include?(type)
      define_method(name.to_sym) do
        evaluate_nodes(xpath, type, options[:format], &block)
      end
      register(name) unless options[:private]
    end

    def child_node(name, node_class_name, xpath, options = {}, &block)
      define_method(name.to_sym) do
        evaluate_child_node(node_class_name, find_node(xpath), &block)
      end
      register(name) unless options[:private]
    end

    def child_array_node(name, node_class_name, xpath, options = {}, &block)
      define_method(name.to_sym) do
        evaluate_child_nodes(node_class_name, xpath, &block)
      end
      register(name) unless options[:private]
    end

    def nodes
      @nodes ||= []
    end

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
