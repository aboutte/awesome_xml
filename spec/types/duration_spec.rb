# frozen_string_literal: true

require File.expand_path("../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration do
  let(:duration) { described_class.new(node, options) }

  describe '#evaluate' do
    subject { duration.evaluate }

    let(:node) { Nokogiri::XML(xml).at_xpath('/duration') }
    let(:xml) { '<duration>12.34</duration>' }

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
          let(:xml) { '<duration>12:34</duration>' }

          specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
        end

        context 'and duration string is empty' do
          let(:xml) { '<duration></duration>' }

          context 'and default_empty option is not set' do
            it { is_expected.to eq nil }
          end

          context 'and default_empty option is set' do
            let(:options) { { format: '{M}.{S}', default_empty: 1.hour } }

            it { is_expected.to eq 1.hour }
          end
        end

        context 'and duration node does not exist' do
          let(:xml) { '<duratio></duratio>' }

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
            let(:xml) { '<duration>.</duration>' }

            it { is_expected.to eq 0.seconds }
          end

          context 'and the duration string does not conform' do
            let(:xml) { '<duration>:</duration>' }

            specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
          end

          context 'and the duration string has additional characters' do
            let(:xml) { '<duration>.12</duration>' }

            it { is_expected.to eq 0.seconds }
          end
        end

        context 'when the format is a simple dynamic string' do
          context 'without parse length' do
            context 'without delimiter' do
              let(:options) { { format: '{M}' } }

              context 'and the duration string conforms' do
                let(:xml) { '<duration>12</duration>' }

                it { is_expected.to eq 12.minutes }
              end

              context 'and the duration string does not conform' do
                let(:xml) { '<duration>12.</duration>' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end
            end

            context 'with delimiter' do
              let(:options) { { format: '{M}.' } }

              context 'and the duration string conforms exactly' do
                let(:xml) { '<duration>123.</duration>' }

                it { is_expected.to eq 123.minutes }
              end

              context 'and the duration string is missing the delimiter' do
                let(:xml) { '<duration>12</duration>' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end

              context 'and the duration string is missing the number' do
                let(:xml) { '<duration>.</duration>' }

                it { is_expected.to eq 0.seconds }
              end
            end
          end

          context 'with parse length' do
            context 'without delimiter' do
              let(:options) { { format: '{M3}' } }

              context 'and the duration string conforms exactly' do
                let(:xml) { '<duration>123</duration>' }

                it { is_expected.to eq 123.minutes }
              end

              context 'and the duration string has fewer characters' do
                let(:xml) { '<duration>12</duration>' }

                it { is_expected.to eq 12.minutes }
              end

              context 'and the duration string has additional characters' do
                let(:xml) { '<duration>123.</duration>' }

                it { is_expected.to eq 123.minutes }
              end
            end

            context 'with delimiter' do
              let(:options) { { format: '{M3}:' } }

              context 'and the duration string conforms exactly' do
                let(:xml) { '<duration>123:</duration>' }

                it { is_expected.to eq 123.minutes }
              end

              context 'and the duration string has fewer characters' do
                let(:xml) { '<duration>12:</duration>' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end

              context 'and the duration string has additional characters' do
                let(:xml) { '<duration>1234:</duration>' }

                specify { expect { subject }.to raise_error(described_class::ChunkParser::FormatMismatch) }
              end

              context 'and the duration string is missing the delimiter' do
                let(:xml) { '<duration>123</duration>' }

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
end

