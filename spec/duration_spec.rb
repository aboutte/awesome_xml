# frozen_string_literal: true

require File.expand_path("../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Duration do
  let(:duration) { described_class.new(arguments) }

  describe '.new' do
    subject { duration }

    context 'passing nothing' do
      subject { described_class.new }

      specify do
        expect(subject.days).to eq nil
        expect(subject.hours).to eq nil
        expect(subject.minutes).to eq nil
        expect(subject.seconds).to eq nil
      end
    end

    context 'passing a unit with value' do
      let(:arguments) { { days: 5 } }

      specify do
        expect(subject.days).to eq 5
        expect(subject.hours).to eq nil
        expect(subject.minutes).to eq nil
        expect(subject.seconds).to eq nil
      end
    end

    context 'passing several units with values' do
      let(:arguments) { { minutes: 9, days: 5 } }

      specify do
        expect(subject.days).to eq 5
        expect(subject.hours).to eq nil
        expect(subject.minutes).to eq 9
        expect(subject.seconds).to eq nil
      end
    end

    context 'passing a wrong unit' do
      let(:arguments) { { minuts: 9 } }

      specify { expect { subject }.to raise_error(described_class::UnknownTimeUnit) }
    end

    context 'passing something else than a hash' do
      let(:arguments) { nil }

      specify { expect { subject }.to raise_error(described_class::InvalidInitializeArguments) }
    end
  end

  describe '#duration' do
    subject { duration.duration }

    context 'when no values are set' do
      let(:arguments) { {} }

      it { is_expected.to eq 0.seconds }
    end

    context 'when some values are set' do
      let(:arguments) { { days: 2, minutes: 100 } }

      it { is_expected.to eq 2.days + 100.minutes }
    end
  end

  describe '#+' do
    subject { duration + other_duration }

    let(:other_duration) { described_class.new(other_arguments) }

    context 'no values are doubled' do
      let(:arguments) { { days: 2, hours: 14 } }
      let(:other_arguments) { { minutes: 37, seconds: 40 } }

      specify do
        expect(subject.days).to eq 2
        expect(subject.hours).to eq 14
        expect(subject.minutes).to eq 37
        expect(subject.seconds).to eq 40
      end
    end

    context 'some values are doubled' do
      let(:arguments) { { days: 2, hours: 14 } }
      let(:other_arguments) { { hours: 37, minutes: 40 } }

      specify { expect { subject }.to raise_error(described_class::DoubleValueAssignment) }
    end
  end
end
