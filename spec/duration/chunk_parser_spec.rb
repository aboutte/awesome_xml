# frozen_string_literal: true

require File.expand_path("../../../lib/awesome-xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration::ChunkParser do
  let(:chunk_parser) { described_class.new(duration_string_chunk, format_chunk) }
  let(:format_chunk) { double }
  before do
    allow(format_chunk).to receive(:dynamic?).and_return dynamic
  end

  describe '#duration' do
    subject { chunk_parser.duration }

    context 'when the format chunk is dynamic' do
      let(:dynamic) { true }
      before { allow(format_chunk).to receive(:unit).and_return(unit) }

      context 'when unit is days' do
        let(:unit) { :days }
        let(:duration_string_chunk) { '312' }

        context 'when duration string chunk is a valid integer' do
          it { is_expected.to eq 312.days }
        end

        context 'when duration string chunk is not a valid integer' do
          let(:duration_string_chunk) { '3.12' }

           specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
        end
      end

      context 'when unit is hours' do
        let(:unit) { :hours }
        let(:duration_string_chunk) { '123' }

        context 'when duration string chunk is a valid integer' do
          it { is_expected.to eq 123.hours }
        end

        context 'when duration string chunk is not a valid integer' do
          let(:duration_string_chunk) { '3.12' }

           specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
        end
      end

      context 'when unit is minutes' do
        let(:unit) { :minutes }
        let(:duration_string_chunk) { '234' }

        context 'when duration string chunk is a valid integer' do
          it { is_expected.to eq 234.minutes }
        end

        context 'when duration string chunk is not a valid integer' do
          let(:duration_string_chunk) { '3.12' }

           specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
        end
      end

      context 'when unit is seconds' do
        let(:unit) { :seconds }
        let(:duration_string_chunk) { '432' }

        context 'when duration string chunk is a valid integer' do
          it { is_expected.to eq 432.seconds }
        end

        context 'when duration string chunk is not a valid integer' do
          let(:duration_string_chunk) { '3.12' }

           specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
        end
      end

      context 'when duration string chunk is empty' do
        let(:unit) { :seconds }
        let(:duration_string_chunk) { '' }

        it { is_expected.to eq 0.seconds }
      end
    end

    context 'when format chunk is static' do
      let(:dynamic) { false }
      before { allow(format_chunk).to receive(:to_s).and_return(format_chunk_string) }

      context 'when format chunk characters and duration format string match' do
        let(:format_chunk_string) { './' }
        let(:duration_string_chunk) { './' }

        it { is_expected.to eq 0.seconds }
      end

      context 'when format chunk characters and duration format string do not match' do
        let(:format_chunk_string) { './' }
        let(:duration_string_chunk) { '.' }

        specify { expect { subject }.to raise_error(described_class::FormatMismatch) }
      end
    end
  end
end
