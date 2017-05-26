# frozen_string_literal: true

# This class's responsibility is to build an XPath from specified options.
module AwesomeXML
  class NodeXPath
    attr_reader :node_name, :specific_xpath, :tag_type, :look_for, :array
    private :node_name, :specific_xpath, :tag_type, :look_for, :array

    # Initialize this class by providing the name of the `AwesomeXML` node and an options hash.
    # For more information on how the options work, please refer to the README.
    def initialize(node_name, options)
      @node_name = node_name
      @specific_xpath = options[:xpath]
      @tag_type = options[:tag_type]
      @look_for = options[:look_for]
      @array = options[:array]
    end

    # Returns a String representing an XPath built from the options passed in at initialization time.
    def xpath
      specific_xpath || xpath_by_tag_type
    end

  private

    def xpath_by_tag_type
      case tag_type
      when :attribute
        "./@#{tag_name}"
      when :value
        "."
      else
        "./#{tag_name}"
      end
    end

    def node_name_singular
      array ? node_name.to_s.singularize.to_sym : node_name
    end

    def tag_name
      look_for || node_name_singular
    end
  end
end
