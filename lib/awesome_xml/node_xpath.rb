# frozen_string_literal: true

# This class's responsibility is to build an XPath from specified options.
module AwesomeXML
  class NodeXPath
    attr_reader :node_name, :specific_xpath, :element_option, :attribute_option, :self_option, :array
    private :node_name, :specific_xpath, :element_option, :attribute_option, :self_option, :array

    # Initialize this class by providing the name of the `AwesomeXML` node and an options hash.
    # For more information on how the options work, please refer to the README.
    def initialize(node_name, options)
      @node_name = node_name
      @specific_xpath = options[:xpath]
      @element_option = options[:element]
      @attribute_option = options[:attribute]
      @self_option = options[:self]
      @look_for = options[:look_for]
      @array = options[:array]
    end

    # Returns a String representing an XPath built from the options passed in at initialization time.
    def xpath
      specific_xpath || xpath_by_tag_type
    end

  private

    def xpath_by_tag_type
      if attribute_option
        "./@#{tag_name(attribute_option)}"
      elsif self_option
        "."
      else
        "./#{tag_name(element_option)}"
      end
    end

    def node_name_singular
      array ? node_name.to_s.singularize.to_sym : node_name
    end

    def tag_name(option)
      (option if option != true) || node_name_singular
    end
  end
end
