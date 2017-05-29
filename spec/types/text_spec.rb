# frozen_string_literal: true

require File.expand_path("../../../lib/awesome-xml.rb", __FILE__)

RSpec.describe AwesomeXML::Text do
  describe '#evaluate' do
    subject { text.evaluate }

    let(:text) { described_class.new(node, options) }
    let(:node) { Nokogiri::XML(xml).at_xpath('/text') }
    let(:options) { {} }

    context 'when text is present' do
      let(:xml) { '<text>TExT</text>' }

      it { is_expected.to eq 'TExT' }
    end

    context 'when text is empty' do
      let(:xml) { '<text/>' }

      context 'and default_empty option is not set' do
        it { is_expected.to eq '' }
      end

      context 'and default_empty option is set' do
        let(:options) { { default_empty: 'default' } }

        it { is_expected.to eq 'default' }
      end
    end

    context 'when node does not exist' do
      let(:xml) { '<texxt/>' }

      context 'and default option is not set' do
        it { is_expected.to eq nil }
      end

      context 'and default option is set' do
        let(:options) { { default: '' } }

        it { is_expected.to eq '' }
      end
    end
  end
end
