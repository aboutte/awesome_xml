# frozen_string_literal: true

# A class that knows how to not parse but simply pass on a node.
module AwesomeXML
  class Void
    attr_reader :node
    private :node

    def initialize(node, options)
      @node = node
      @options = options
    end

    def evaluate
      node
    end

    def self.parsing_type?
      false
    end
  end
end
