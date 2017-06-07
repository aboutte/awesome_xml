# frozen_string_literal: true

require File.expand_path("../../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::Void do
  describe '#evaluate' do
    subject { void.evaluate }

    let(:void) { described_class.new(string, options) }
    let(:string) { 'void' }
    let(:options) { {} }

    it { is_expected.to eq string }
  end

  describe '.parsing_type?' do
    subject { described_class.parsing_type? }

    it { is_expected.to be false }
  end
end
