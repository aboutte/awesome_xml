# frozen_string_literal: true

require File.expand_path("../../../lib/awesome-xml.rb", __FILE__)

RSpec.describe AwesomeXML::Integer do
  describe '#evaluate' do
    subject { integer.evaluate }

    let(:integer) { described_class.new(node, options) }
    let(:node) { Nokogiri::XML(xml).at_xpath('/integer') }
    let(:options) { {} }

    context 'when text is present' do
      context 'and it forms a number' do
        let(:xml) { '<integer>123</integer>' }

        it { is_expected.to eq 123 }
      end

      context 'and it does not form a number' do
        let(:xml) { '<integer>abc</integer>' }

        it { is_expected.to eq 0 }
      end
    end

    context 'when text is empty' do
      let(:xml) { '<integer/>' }

      context 'and default_empty option is not set' do
        it { is_expected.to eq nil }
      end

      context 'and default_empty option is set' do
        let(:options) { { default_empty: -1 } }

        it { is_expected.to eq -1 }
      end
    end

    context 'when node does not exist' do
      let(:xml) { '<integr/>' }

      context 'and default option is not set' do
        it { is_expected.to eq nil }
      end

      context 'and default option is set' do
        let(:options) { { default: 10 } }

        it { is_expected.to eq 10 }
      end
    end
  end
end
