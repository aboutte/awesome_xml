# frozen_string_literal: true

# This class's responsibility is to build an XPath from specified options.
module AwesomeXML
  class NodeXPath
    attr_reader :node_name, :options
    private :node_name, :options

    # Initialize this class by providing the name of the `AwesomeXML` node and an options hash.
    # For more information on how the options work, please refer to the README.
    def initialize(node_name, options)
      @node_name = node_name
      @options = options
    end

    # Returns a String representing an XPath built from the options passed in at initialization time.
    def xpath
      options[:xpath] || xpath_by_tag_type
    end

  private

    def xpath_by_tag_type
      if options[:attribute]
        "./@#{tag_name(options[:attribute])}"
      elsif options[:attribute_name]
        "./@#{tag_name(true)}"
      elsif options[:self] || options[:self_name]
        "."
      elsif options[:element_name]
        "./#{tag_name(true)}"
      else
        "./#{tag_name(options[:element])}"
      end
    end

    def node_name_singular
      options[:array] ? node_name.to_s.singularize.to_sym : node_name
    end

    def tag_name(option)
      (option if option != true) || node_name_singular
    end
  end
end
