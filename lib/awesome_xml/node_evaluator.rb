# frozen_string_literal: true

# This class is responsible for parsing a specific value from an XML document given all the
# necessary information.
module AwesomeXML
  class NodeEvaluator
    attr_reader :xml, :xpath, :type_class, :options
    private :xml, :xpath, :type_class, :options

    # Initialize an instance of this class with a Nokogiri::XML object, a string representing
    # an XPath to the value(s) you want to parse, a type class (see `AwesomeXML::Type` for more
    # info), and an options hash.
    def initialize(xml, xpath, type_class, options)
      @xml = xml
      @xpath = xpath
      @type_class = type_class
      @options = options
    end

    # Parses one or several nodes, depending on the `options[:array]` setting, according to the
    # type passed in in the form of a class that handles the conversion.
    def call
      if options[:array]
        all_nodes.map { |node| type_class.new(node, options).evaluate }
      else
        type_class.new(first_node, options).evaluate
      end
    end

  private

    def all_nodes
      xml_in_context&.xpath(xpath)
    end

    def first_node
      xml_in_context&.at_xpath(xpath)
    end

    def xml_in_context
      options[:local_context] ? xml&.xpath(options[:local_context]) : xml
    end
  end
end
