# frozen_string_literal: true

FILES = %w(
  native_type
  node_evaluator
  node_xpath
  types/text
  types/integer
  types/float
  types/duration
  types/date_time
  types/void
  type
  class_methods
  duration/chunk_parser
  duration/format
  duration/format/dynamic_chunk
  duration/format/static_chunk
).freeze

FILES.each do |file|
  require File.expand_path("../awesome_xml/#{file}.rb", __FILE__)
end

require 'nokogiri'
require 'active_support/time'

# This module should be included by every class wishing to pose as an `AwesomeXML` node.
# It gives access to the methods described in this module and also to class methods in the
# `AwesomeXML::ClassMethods` module.
module AwesomeXML
  def self.included(base)
    base.class_eval do
      base.extend(AwesomeXML::ClassMethods)
    end
  end

  attr_reader :xml, :parent_node
  private :xml

  # Pass in a string representing valid XML and an options hash to initialize a class that
  # includes `AwesomeXML`.
  def initialize(xml = nil, options = {})
    @xml = xml
    @parent_node = options[:parent_node]
  end

  # This methods runs the parsing operations and assigns the parsed values to the corresponding
  # attribute of each node defined in the class. Returns the class instance.
  def parse
    @xml = Nokogiri::XML(xml).remove_namespaces!
    @xml = xml&.xpath(self.class.context) if self.class.context.present?
    parse_values
    self
  end

  # Call this method to the names and parsed values of the non-private nodes of your class in a
  # hash, structured as they were defined. Goes down the rabbit hole and calls `evaluate` on child
  # nodes, too.
  def evaluate
    parse_values
    Hash[self.class.public_nodes.map { |node| [node, public_send(node)] }]
  end
  alias_method :to_hash, :evaluate

private

  def parse_values
    self.class.nodes.each { |node| public_send("parse_#{node}") }
  end

  def evaluate_nodes(xpath, type_class, options = {}, &block)
    evaluated_node = AwesomeXML::NodeEvaluator.new(xml, xpath, type_class, options.merge(parent_node: self)).call
    if block_given?
      yield(evaluated_node, self)
    else
      evaluated_node
    end
  end
end
