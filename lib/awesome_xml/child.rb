# frozen_string_literal: true

module AwesomeXML
  module Child
    include AwesomeXML::Node

    def self.included(base)
      base.class_eval do
        base.extend(AwesomeXML::BuilderMethods)
      end
    end

    attr_reader :data, :parent_node
    private :data

    def initialize(data, parent_node)
      @data = data
      @parent_node = parent_node
    end

  private

    def xml
      data
    end
  end
end
