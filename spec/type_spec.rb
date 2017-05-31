# frozen_string_literal: true

require File.expand_path("../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Type do
  describe '.for' do
    subject { described_class.for(type, class_name) }
    let(:class_name) { 'AwesomeXML::TestClass' }

    context 'type is given as a Symbol' do
      context 'which is :text' do
        let(:type) { :text }

        it { is_expected.to eq AwesomeXML::Text }
      end

      context 'which is :integer' do
        let(:type) { :integer }

        it { is_expected.to eq AwesomeXML::Integer }
      end

      context 'which is :float' do
        let(:type) { :float }

        it { is_expected.to eq AwesomeXML::Float }
      end

      context 'which is :duration' do
        let(:type) { :duration }

        it { is_expected.to eq AwesomeXML::Duration }
      end

      context 'which is :date_time' do
        let(:type) { :date_time }

        it { is_expected.to eq AwesomeXML::DateTime }
      end

      context 'which is anything else' do
        let(:type) { :abcdef }

        specify { expect { subject }.to raise_error described_class::UnknownNodeType }
      end
    end

    context 'type is given as a Class' do
      let(:type) { AwesomeXML::TestClass::Subclass }

      it { is_expected.to eq AwesomeXML::TestClass::Subclass }
    end

    context 'type is given as a String' do
      let(:type) { 'Subclass' }

      it { is_expected.to eq AwesomeXML::TestClass::Subclass }
    end
  end
end

module AwesomeXML
  class TestClass
    class Subclass
    end
  end
end

