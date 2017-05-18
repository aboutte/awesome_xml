# frozen_string_literal: true

require File.expand_path("../../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration::Format::StaticChunk do
  let(:static_chunk) { described_class.new }
  let(:format_chars) { 'abdef'.chars }

  before { static_chunk.format_chars = format_chars }

  describe '#to_s' do
    subject { static_chunk.to_s }

    it { is_expected.to eq 'abdef' }
  end

  describe '#parse_length' do
    subject { static_chunk.parse_length }

    it { is_expected.to eq 5 }
  end

  describe '#dynamic?' do
    subject { static_chunk.dynamic? }

    it { is_expected.to eq false }
  end
end
