# frozen_string_literal: true

FILES = %w(
  node
  root
  child
  builder_methods
  duration
  duration/chunk_parser
  duration/format
  duration/parser
  duration/format/dynamic_chunk
  duration/format/static_chunk
).freeze

FILES.each do |file|
  require File.expand_path("../awesome_xml/#{file}.rb", __FILE__)
end

require 'nokogiri'
require 'active_support/all'