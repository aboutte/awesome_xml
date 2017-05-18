# frozen_string_literal: true

# Include this module in your top class holding nodes.
module AwesomeXML
  module Root
    include AwesomeXML::Node

    def self.included(base)
      base.extend(AwesomeXML::BuilderMethods)
    end

  private

    def xml
      @xml ||= Nokogiri::XML(data).remove_namespaces!
    end
  end
end
