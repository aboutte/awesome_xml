# frozen_string_literal: true

require File.expand_path("../../../../lib/awesome-xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration::Format::DynamicChunk do
  let(:dynamic_chunk) { described_class.new }

  before do
    dynamic_chunk.format_chars = format_chars
    dynamic_chunk.delimiter = delimiter
  end

  let(:format_chars) { 'M23'.chars }
  let(:delimiter) { '.' }

  describe '#to_s' do
    subject { dynamic_chunk.to_s }

    it { is_expected.to eq 'M23.' }
  end

  describe '#delimiter' do
    subject { dynamic_chunk.delimiter }

    it { is_expected.to eq '.' }
  end

  describe '#unit' do
    subject { dynamic_chunk.unit }

    context 'when type is days' do
      let(:format_chars) { %w(D 2) }

      it { is_expected.to eq :days }
    end

    context 'when type is hours' do
      let(:format_chars) { %w(H 2) }

      it { is_expected.to eq :hours }
    end

    context 'when type is minutes' do
      let(:format_chars) { %w(M 2) }

      it { is_expected.to eq :minutes }
    end

    context 'when type is seconds' do
      let(:format_chars) { %w(S 2) }

      it { is_expected.to eq :seconds }
    end

    context 'when type is unknown' do
      let(:format_chars) { %w(F 2) }

      specify { expect { subject }.to raise_error(described_class::InvalidDurationUnit) }
    end
  end

  describe '#parse_length' do
    subject { dynamic_chunk.parse_length }

    context 'when length is one digit' do
      let(:format_chars) { %w(D 4) }

      it { is_expected.to eq 4 }
    end

    context 'when length is two digits' do
      let(:format_chars) { %w(S 1 0) }

      it { is_expected.to eq 10 }
    end

    context 'when length is missing' do
      let(:format_chars) { %w(H) }

      it { is_expected.to eq 0 }
    end

    context 'when length is zero' do
      let(:format_chars) { %w(M 0) }

      it { is_expected.to eq 0 }
    end

    context 'when length is not a number' do
      let(:format_chars) { %w(M x) }

      specify { expect { subject }.to raise_error(described_class::InvalidParseLength) }
    end
  end

  describe '#dynamic?' do
    subject { dynamic_chunk.dynamic? }

    it { is_expected.to eq true }
  end
end
