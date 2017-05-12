# frozen_string_literal: true

module AwesomeXML
  module Root
    include AwesomeXML::Node

    def self.included(base)
      base.extend(AwesomeXML::BuilderMethods)
    end

    def to_hash
      Hash[self.class.nodes.map { |node| [node, public_send(node)] }]
    end

  private

    def xml
      @xml ||= Nokogiri::XML(data).remove_namespaces!
    end
  end
end
