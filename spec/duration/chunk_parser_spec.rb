# frozen_string_literal: true

require File.expand_path("../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration::ChunkParser do
  let(:chunk_parser) { described_class.new(duration_string_chunk, format_chunk) }

  describe '#duration' do
    subject { chunk_parser.duration }

    context 'when the format chunk is dynamic' do
      let(:format_chunk) { AwesomeXML::Duration::Format::DynamicChunk.new }
      let(:delimiter) { nil }

      before do
        format_chunk.format_chars = format_chars
      end

      context 'when unit is days' do
        let(:format_chars) { 'D' }

        context 'when duration string chunk is a valid integer' do
          let(:duration_string_chunk) { '312' }

          it { is_expected.to be_a(AwesomeXML::Duration) }
          specify do
            expect(subject.days).to eq 312
            expect(subject.hours).to eq nil
            expect(subject.minutes).to eq nil
            expect(subject.seconds).to eq nil
          end
        end

        context 'when duration string chunk is not a valid integer' do
          let(:duration_string_chunk) { '3.12' }

           specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
        end
      end

      context 'when unit is hours' do
        let(:format_chars) { 'H' }
        let(:duration_string_chunk) { '123' }

        context 'when duration string chunk is a valid integer' do
          it { is_expected.to be_a(AwesomeXML::Duration) }
          specify do
            expect(subject.days).to eq nil
            expect(subject.hours).to eq 123
            expect(subject.minutes).to eq nil
            expect(subject.seconds).to eq nil
          end
        end

        context 'when duration string chunk is not a valid integer' do
          let(:duration_string_chunk) { '3.12' }

           specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
        end
      end

      context 'when unit is minutes' do
        let(:format_chars) { 'M' }
        let(:duration_string_chunk) { '234' }

        context 'when duration string chunk is a valid integer' do
          it { is_expected.to be_a(AwesomeXML::Duration) }
          specify do
            expect(subject.days).to eq nil
            expect(subject.hours).to eq nil
            expect(subject.minutes).to eq 234
            expect(subject.seconds).to eq nil
          end
        end

        context 'when duration string chunk is not a valid integer' do
          let(:duration_string_chunk) { '3.12' }

           specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
        end
      end

      context 'when unit is seconds' do
        let(:format_chars) { 'S' }
        let(:duration_string_chunk) { '432' }

        context 'when duration string chunk is a valid integer' do
          it { is_expected.to be_a(AwesomeXML::Duration) }
          specify do
            expect(subject.days).to eq nil
            expect(subject.hours).to eq nil
            expect(subject.minutes).to eq nil
            expect(subject.seconds).to eq 432
          end
        end

        context 'when duration string chunk is not a valid integer' do
          let(:duration_string_chunk) { '3.12' }

           specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
        end
      end
    end
  end
end
