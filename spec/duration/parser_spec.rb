# frozen_string_literal: true

require File.expand_path("../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration::Parser do
  let(:parser) { described_class.new(timestamp, format_string) }

  describe '#duration' do
    subject { parser.duration }

    context 'when format string is well formed' do
      context 'when format string consists of one fixed length duration section' do
        let(:format_string) { '{H2}' }

        context 'and the timestamp provides correct number of characters' do
          let(:timestamp) { '24' }

          it { is_expected.to eq 24.hours }
        end

        context 'and the timestamp provides less characters' do
          let(:timestamp) { '4' }

          it { is_expected.to eq 4.hours }
        end

        context 'and the timestamp provides more characters' do
          let(:timestamp) { '234' }

          it { is_expected.to eq 23.hours }
        end
      end

      context 'when format string consists of two duration sections' do
        let(:format_string) { '{H2}{M2}' }

        context 'and the timestamp provides number characters for both' do
          let(:timestamp) { '1234' }

          it { is_expected.to eq 12.hours + 34.minutes }
        end

        context 'and the timestamp does not provide number characters for both' do
          let(:timestamp) { '1' }

          it { is_expected.to eq 1.hour }
        end

        context 'and the timestamp provides more number characters' do
          let(:timestamp) { '12345' }

          it { is_expected.to eq 12.hours + 34.minutes }
        end
      end

      context 'when format string consists of two fixed length duration sections with some fixed characters' do
        let(:format_string) { 'h{H2}:{M2};' }

        context 'and the timestamp follows the format exactly' do
          let(:timestamp) { 'h12:34;' }

          it { is_expected.to eq 12.hours + 34.minutes }
        end

        context 'and the timestamp is missing a fixed character' do
          let(:timestamp) { '12:34;' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the timestamp is missing a fixed character at the end of the string' do
          let(:timestamp) { 'h12:34' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the timestamp is providing not enough number characters' do
          let(:timestamp) { '12:3;' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the timestamp provides more characters' do
          let(:timestamp) { '12:345;' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end
      end

      context 'when format string consists of one variable length duration section' do
        let(:format_string) { '{S}' }

        context 'and the timestamp provides any number of number characters' do
          let(:timestamp) { '1234' }

          it { is_expected.to eq 1234.seconds }
        end

        context 'and the timestamp provides any number of number characters but an additional character' do
          let(:timestamp) { '1234.' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end
      end

      context 'when format string consists of two variable length duration sections separated by a fixed character' do
        let(:format_string) { '{M}:{S}' }

        context 'and the timestamp follows the format exactly' do
          let(:timestamp) { '1:34' }

          it { is_expected.to eq 1.minute + 34.seconds }
        end

        context 'and the timestamp is missing the fixed character' do
          let(:timestamp) { '1234' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the timestamp has the wrong a fixed character' do
          let(:timestamp) { '12.34' }

          specify { expect { subject }.to raise_error(AwesomeXML::Duration::ChunkParser::FormatMismatch) }
        end

        context 'and the timestamp is not providing characters for the first section' do
          let(:timestamp) { ':34' }

          it { is_expected.to eq 34.seconds }
        end

        context 'and the timestamp is not providing characters for the last section' do
          let(:timestamp) { '34:' }

          it { is_expected.to eq 34.minutes }
        end
      end
    end

    context 'when format string is not well formed' do
      context 'because an unknown time unit is specified' do
        let(:format_string) { '{F}' }
        let(:timestamp) { 'adfvabdl' }

        specify { expect { subject }.to raise_error(AwesomeXML::Duration::Format::DynamicChunk::InvalidDurationUnit) }
      end

      context 'because an invalid parse length is specified' do
        let(:format_string) { '{MM}' }
        let(:timestamp) { '123' }

        specify { expect { subject }.to raise_error(AwesomeXML::Duration::Format::DynamicChunk::InvalidParseLength) }
      end

      context 'because there are two dynamic format chunks with the same unit' do
        let(:format_string) { '{M2}.{M4}' }
        let(:timestamp) { '12.3456' }

        specify { expect { subject }.to raise_error(AwesomeXML::Duration::DoubleValueAssignment) }
      end
    end
  end
end
