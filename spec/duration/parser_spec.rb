# frozen_string_literal: true

require File.expand_path("../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration::Parser do
  let(:parser) { described_class.new(duration_string, format_string) }

  describe '#duration' do
    subject { parser.duration }

    context 'when format string is well formed' do
      context 'when format string consists of one fixed length duration section' do
        let(:format_string) { '{H2}' }

        context 'and the duration_string provides correct number of characters' do
          let(:duration_string) { '24' }

          it { is_expected.to eq 24.hours }
        end

        context 'and the duration_string provides less characters' do
          let(:duration_string) { '4' }

          it { is_expected.to eq 4.hours }
        end

        context 'and the duration_string provides more characters' do
          let(:duration_string) { '234' }

          it { is_expected.to eq 23.hours }
        end
      end

      context 'when format string consists of two duration sections' do
        let(:format_string) { '{H2}{M2}' }

        context 'and the duration_string provides number characters for both' do
          let(:duration_string) { '1234' }

          it { is_expected.to eq 12.hours + 34.minutes }
        end

        context 'and the duration_string does not provide number characters for both' do
          let(:duration_string) { '1' }

          it { is_expected.to eq 1.hour }
        end

        context 'and the duration_string provides more number characters' do
          let(:duration_string) { '12345' }

          it { is_expected.to eq 12.hours + 34.minutes }
        end
      end

      context 'when format string consists of two fixed length duration sections with some fixed characters' do
        let(:format_string) { 'h{H2}:{M2};' }

        context 'and the duration_string follows the format exactly' do
          let(:duration_string) { 'h12:34;' }

          it { is_expected.to eq 12.hours + 34.minutes }
        end

        context 'and the duration_string is missing a fixed character' do
          let(:duration_string) { '12:34;' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the duration_string is missing a fixed character at the end of the string' do
          let(:duration_string) { 'h12:34' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the duration_string is providing not enough number characters' do
          let(:duration_string) { '12:3;' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the duration_string provides more characters' do
          let(:duration_string) { '12:345;' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end
      end

      context 'when format string consists of one variable length duration section' do
        let(:format_string) { '{S}' }

        context 'and the duration_string provides any number of number characters' do
          let(:duration_string) { '1234' }

          it { is_expected.to eq 1234.seconds }
        end

        context 'and the duration_string provides any number of number characters but an additional character' do
          let(:duration_string) { '1234.' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end
      end

      context 'when format string consists of two variable length duration sections separated by a fixed character' do
        let(:format_string) { '{M}:{S}' }

        context 'and the duration_string follows the format exactly' do
          let(:duration_string) { '1:34' }

          it { is_expected.to eq 1.minute + 34.seconds }
        end

        context 'and the duration_string is missing the fixed character' do
          let(:duration_string) { '1234' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the duration_string has the wrong a fixed character' do
          let(:duration_string) { '12.34' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the duration_string is not providing characters for the first section' do
          let(:duration_string) { ':34' }

          it { is_expected.to eq 34.seconds }
        end

        context 'and the duration_string is not providing characters for the last section' do
          let(:duration_string) { '34:' }

          it { is_expected.to eq 34.minutes }
        end
      end
    end

    context 'when format string is not well formed' do
      context 'because an unknown time unit is specified' do
        let(:format_string) { '{F}' }
        let(:duration_string) { 'adfvabdl' }

        specify { expect { subject }.to raise_error(AwesomeXML::Duration::Format::DynamicChunk::InvalidDurationUnit) }
      end

      context 'because an invalid parse length is specified' do
        let(:format_string) { '{MM}' }
        let(:duration_string) { '123' }

        specify { expect { subject }.to raise_error(AwesomeXML::Duration::Format::DynamicChunk::InvalidParseLength) }
      end

      context 'because there are two dynamic format chunks with the same unit' do
        let(:format_string) { '{M2}.{M4}' }
        let(:duration_string) { '12.3456' }

        specify { expect { subject }.to raise_error(AwesomeXML::Duration::DoubleValueAssignment) }
      end
    end
  end
end
