# frozen_string_literal: true

require File.expand_path("../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration::Format do
  let(:format) { described_class.new(format_string) }

  describe '#chunks' do
    subject { format.chunks }

    context 'when format string consists of a single static chunk' do
      let(:format_string) { 'xy' }

      it { is_expected.to contain_exactly(kind_of(AwesomeXML::Duration::Format::StaticChunk)) }
      specify { expect(subject.first.to_s).to eq format_string }
    end

    context 'when format string consists of a single dynamic chunk' do
      let(:format_string) { '{D2}' }

      it { is_expected.to contain_exactly(kind_of(AwesomeXML::Duration::Format::DynamicChunk)) }
      specify { expect(subject.first.unit).to eq :days }
      specify { expect(subject.first.parse_length).to eq 2 }
      specify { expect(subject.first.delimiter).to eq nil }
    end

    context 'when format string consists of two dynamic chunks' do
      let(:format_string) { '{D2}{H}' }

      it do
        is_expected.to contain_exactly(
          kind_of(AwesomeXML::Duration::Format::DynamicChunk),
          kind_of(AwesomeXML::Duration::Format::DynamicChunk)
        )
      end
      specify { expect(subject.first.unit).to eq :days }
      specify { expect(subject.first.parse_length).to eq 2 }
      specify { expect(subject.first.delimiter).to eq nil }
      specify { expect(subject.last.unit).to eq :hours }
      specify { expect(subject.last.parse_length).to eq 0 }
      specify { expect(subject.last.delimiter).to eq nil }
    end

    context 'when format string consists of two dynamic chunks separated by a static chunk' do
      let(:format_string) { '{D2}.{H}' }

      it do
        is_expected.to contain_exactly(
          kind_of(AwesomeXML::Duration::Format::DynamicChunk),
          kind_of(AwesomeXML::Duration::Format::StaticChunk),
          kind_of(AwesomeXML::Duration::Format::DynamicChunk)
        )
      end
      specify { expect(subject.first.unit).to eq :days }
      specify { expect(subject.first.parse_length).to eq 2 }
      specify { expect(subject.first.delimiter).to eq '.' }
      specify { expect(subject[1].to_s).to eq '.' }
      specify { expect(subject.last.unit).to eq :hours }
      specify { expect(subject.last.parse_length).to eq 0 }
      specify { expect(subject.last.delimiter).to eq nil }
    end

    context 'when format string consists of two dynamic chunks separated and followed by a static chunk' do
      let(:format_string) { '{D2}.{H}xy' }

      it do
        is_expected.to contain_exactly(
          kind_of(AwesomeXML::Duration::Format::DynamicChunk),
          kind_of(AwesomeXML::Duration::Format::StaticChunk),
          kind_of(AwesomeXML::Duration::Format::DynamicChunk),
          kind_of(AwesomeXML::Duration::Format::StaticChunk)
        )
      end
      specify { expect(subject.first.unit).to eq :days }
      specify { expect(subject.first.parse_length).to eq 2 }
      specify { expect(subject.first.delimiter).to eq '.' }
      specify { expect(subject[1].to_s).to eq '.' }
      specify { expect(subject[2].unit).to eq :hours }
      specify { expect(subject[2].parse_length).to eq 0 }
      specify { expect(subject[2].delimiter).to eq 'x' }
      specify { expect(subject.last.to_s).to eq 'xy' }
    end
  end
end
