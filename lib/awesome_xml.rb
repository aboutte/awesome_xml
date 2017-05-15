# frozen_string_literal: true

module AwesomeXML
end

require File.expand_path("../awesome_xml/node.rb", __FILE__)
require File.expand_path("../awesome_xml/root.rb", __FILE__)
require File.expand_path("../awesome_xml/child.rb", __FILE__)
require File.expand_path("../awesome_xml/builder_methods.rb", __FILE__)

require 'nokogiri'
require 'active_support/all'