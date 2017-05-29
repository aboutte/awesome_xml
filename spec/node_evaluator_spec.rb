# frozen_string_literal: true

require File.expand_path("../../lib/awesome-xml.rb", __FILE__)

RSpec.describe AwesomeXML::NodeEvaluator do
  describe '#call' do
    subject { node_evaluator.call }

    let(:node_evaluator) { described_class.new(xml, xpath, type_class, options) }
    let(:xml) { Nokogiri::XML(xml_string) }
    let(:xml_string) { '<doc><text>TEXT</text><text>t.e.x.t.</text></doc>' }
    let(:type_class) { AwesomeXML::MockType }
    let(:xpath) { '/doc/text' }
    let(:options) { {} }

    context 'when xml is valid' do
      context 'when xpath is valid' do
        context 'when nodes exist' do
          context 'when array option not given' do
            context 'when local_context option not given' do
              it { is_expected.to eq 'TEXT' }
            end

            context 'when local_context option given' do
              let(:options) { { local_context: '/doc' } }
              let(:xpath) { './text' }

              it { is_expected.to eq 'TEXT' }
            end
          end

          context 'when array option given' do
            let(:options) { { array: true } }

            it { is_expected.to eq ['TEXT', 't.e.x.t.'] }
          end
        end

        context 'when nodes do not exist' do
          let(:xml_string) { '</texxt>TEXT<texxt>' }

          it { is_expected.to eq nil }
        end
      end

      context 'when xpath is invalid' do
        let(:xpath) { '\xyz' }

        specify { expect { subject }.to raise_error(Nokogiri::XML::XPath::SyntaxError) }
      end
    end

    context 'when xml is invalid' do
      let(:xml_string) { '</text>TEXT<text>' }

      it { is_expected.to eq nil }
    end
  end
end

class AwesomeXML::MockType
  attr_reader :node

  def initialize(node, options)
    @node = node
  end

  def evaluate
    node&.text
  end
end
