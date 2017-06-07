# frozen_string_literal: true

require File.expand_path("../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::DateTime do
  describe '#evaluate' do
    subject { date_time.evaluate }

    let(:date_time) { described_class.new(string, options) }
    let(:string) { '2012.08.04' }
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
          let(:string) { 'abc' }

          specify { expect { subject }.to raise_error(ArgumentError) }
        end

        context 'when timestamp is empty' do
          let(:string) { '' }

          context 'and default_empty option is not set' do
            it { is_expected.to eq nil }
          end

          context 'and default_empty option is set' do
            let(:options) { { default_empty: Date.new(2016, 11, 11) } }

            it { is_expected.to eq Date.new(2016, 11, 11) }
          end
        end

        context 'when timestamp is nil' do
          let(:string) { nil }

          context 'and default option is not set' do
            it { is_expected.to eq nil }
          end

          context 'and default option is set' do
            let(:options) { { default: Date.new(1970, 1, 1) } }

            it { is_expected.to eq Date.new(1970, 1, 1) }
          end
        end
      end
    end
  end

  describe '.parsing_type?' do
    subject { described_class.parsing_type? }

    it { is_expected.to be true }
  end
end
