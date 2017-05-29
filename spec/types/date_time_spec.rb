# frozen_string_literal: true

require File.expand_path("../../../lib/awesome-xml.rb", __FILE__)

RSpec.describe AwesomeXML::DateTime do
  describe '#evaluate' do
    subject { date_time.evaluate }

    let(:date_time) { described_class.new(node, options) }
    let(:node) { Nokogiri::XML(xml).at_xpath('/date_time') }
    let(:xml) { '<date_time>2012.08.04</date_time>' }
    let(:options) { {} }

    context 'when no format option given' do
      let(:options) { {} }

      specify { expect { subject }.to raise_error(described_class::NoFormatProvided) }
    end

    context 'when format option present' do
      context 'when format is valid' do
        let(:options) { { format: '%Y.%m.%d' } }

        context 'and timestamp matches format' do
          it { is_expected.to eq DateTime.new(2012, 8, 4) }
        end

        context 'and timestamp does not match format' do
          let(:xml) { '<date_time>abc</date_time>' }

          specify { expect { subject }.to raise_error(ArgumentError) }
        end
      end
    end
  end
end
