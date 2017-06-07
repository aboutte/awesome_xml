# frozen_string_literal: true

require File.expand_path("../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration do
  let(:duration) { described_class.new(string, options) }

  describe '#evaluate' do
    subject { duration.evaluate }

    let(:string) { '12.34' }

    context 'when no format option given' do
      let(:options) { {} }

      specify { expect { subject }.to raise_error(described_class::NoFormatProvided) }
    end

    context 'when format option present' do
      context 'when format is valid' do
        let(:options) { { format: '{M}.{S}' } }

        context 'and duration string matches format' do
          it { is_expected.to eq 754.seconds }
        end

        context 'and duration string does not match format' do
          let(:string) { '12:34' }

          specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
        end

        context 'and duration string is empty' do
          let(:string) { '' }

          context 'and default_empty option is not set' do
            it { is_expected.to eq nil }
          end

          context 'and default_empty option is set' do
            let(:options) { { format: '{M}.{S}', default_empty: 1.hour } }

            it { is_expected.to eq 1.hour }
          end
        end

        context 'and duration string is nil' do
          let(:string) { nil }

          context 'and default option is not set' do
            it { is_expected.to eq nil }
          end

          context 'and default option is set' do
            let(:options) { { format: '{M}.{S}', default: 1.hour } }

            it { is_expected.to eq 1.hour }
          end
        end

        context 'when the format is a simple static string' do
          let(:options) { { format: '.' } }

          context 'and the duration string conforms' do
            let(:string) { '.' }

            it { is_expected.to eq 0.seconds }
          end

          context 'and the duration string does not conform' do
            let(:string) { ':' }

            specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
          end

          context 'and the duration string has additional characters' do
            let(:string) { '.12' }

            it { is_expected.to eq 0.seconds }
          end
        end

        context 'when the format is a simple dynamic string' do
          context 'without parse length' do
            context 'without delimiter' do
              let(:options) { { format: '{M}' } }

              context 'and the duration string conforms' do
                let(:string) { '12' }

                it { is_expected.to eq 12.minutes }
              end

              context 'and the duration string does not conform' do
                let(:string) { '12.' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end
            end

            context 'with delimiter' do
              let(:options) { { format: '{M}.' } }

              context 'and the duration string conforms exactly' do
                let(:string) { '123.' }

                it { is_expected.to eq 123.minutes }
              end

              context 'and the duration string is missing the delimiter' do
                let(:string) { '12' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end

              context 'and the duration string is missing the number' do
                let(:string) { '.' }

                it { is_expected.to eq 0.seconds }
              end
            end
          end

          context 'with parse length' do
            context 'without delimiter' do
              let(:options) { { format: '{M3}' } }

              context 'and the duration string conforms exactly' do
                let(:string) { '123' }

                it { is_expected.to eq 123.minutes }
              end

              context 'and the duration string has fewer characters' do
                let(:string) { '12' }

                it { is_expected.to eq 12.minutes }
              end

              context 'and the duration string has additional characters' do
                let(:string) { '123.' }

                it { is_expected.to eq 123.minutes }
              end
            end

            context 'with delimiter' do
              let(:options) { { format: '{M3}:' } }

              context 'and the duration string conforms exactly' do
                let(:string) { '123:' }

                it { is_expected.to eq 123.minutes }
              end

              context 'and the duration string has fewer characters' do
                let(:string) { '12:' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end

              context 'and the duration string has additional characters' do
                let(:string) { '1234:' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end

              context 'and the duration string is missing the delimiter' do
                let(:string) { '123' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end
            end
          end
        end
      end

      context 'when format is invalid' do
        let(:options) { { format: '{xy}' } }

        specify { expect { subject }.to raise_error(described_class::Format::DynamicChunk::InvalidParseLength) }
      end

      context 'when format is empty' do
        let(:options) { { format: '' } }

        it { is_expected.to eq 0.seconds }
      end
    end
  end

  describe '.parsing_type?' do
    subject { described_class.parsing_type? }

    it { is_expected.to be true }
  end
end

