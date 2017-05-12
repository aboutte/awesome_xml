# frozen_string_literal: true

module AwesomeXML
  module BuilderMethods
    SIMPLE_TYPES = [:text, :integer].freeze

    def constant_node(name, value, options = {})
      define_method(name.to_sym) do
        value
      end
      register(name) unless options[:private]
    end

    def method_node(name)
      register(name)
    end

    def text_node(*args, &block)
      simple_node(:text, *args, &block)
    end

    def integer_node(*args, &block)
      simple_node(:integer, *args, &block)
    end

    def float_node(*args, &block)
      simple_node(:float, *args, &block)
    end

    def simple_node(type, name, xpath, options = {}, &block)
      define_method(name.to_sym) do
        evaluate_node(xpath, type, &block)
      end
      register(name) unless options[:private]
    end

    def text_array_node(*args, &block)
      simple_array_node(:text, *args, &block)
    end

    def integer_array_node(*args, &block)
      simple_array_node(:integer, *args, &block)
    end

    def float_array_node(*args, &block)
      simple_array_node(:float, *args, &block)
    end

    def simple_array_node(type, name, xpath, options = {}, &block)
      define_method(name.to_sym) do
        evaluate_nodes(xpath, type, &block)
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

    def parse_type(string, type)
      case type
      when :text
        string
      when :integer
        string.to_i if string.present?
      when :float
        string.to_f if string.present?
      end
    end

  private

    def register(node_name)
      @nodes ||= []
      @nodes << node_name.to_sym
    end
  end
end
