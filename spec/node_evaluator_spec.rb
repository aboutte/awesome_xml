# frozen_string_literal: true

require File.expand_path("../../lib/awesome_xml.rb", __FILE__)

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
          context 'when type is not a parsing type' do
            let(:type_class) { AwesomeXML::Void }

            context 'when array option not given' do
              context 'when local_context option not given' do
                it do
                  is_expected.to be_a Nokogiri::XML::Element
                  expect(subject.text).to eq 'TEXT'
                end
              end

              context 'when local_context option given' do
                let(:options) { { element_name: true, local_context: '/doc' } }
                let(:xpath) { './text' }

                it do
                  is_expected.to be_a Nokogiri::XML::Element
                  expect(subject.text).to eq 'TEXT'
                end
              end
            end

            context 'when array option given' do
              let(:options) { { element_name: true, array: true } }

              it do
                is_expected.to contain_exactly(kind_of(Nokogiri::XML::Element), kind_of(Nokogiri::XML::Element))
                expect(subject.first.text).to eq 'TEXT'
                expect(subject.last.text).to eq 't.e.x.t.'
              end
            end
          end

          context 'when type is a parsing type' do
            context 'when :element_name option is given' do
              let(:options) { { element_name: true } }

              context 'when array option not given' do
                context 'when local_context option not given' do
                  it { is_expected.to eq 'text' }
                end

                context 'when local_context option given' do
                  let(:options) { { element_name: true, local_context: '/doc' } }
                  let(:xpath) { './text' }

                  it { is_expected.to eq 'text' }
                end
              end

              context 'when array option given' do
                let(:options) { { element_name: true, array: true } }

                it { is_expected.to eq ['text', 'text'] }
              end
            end

            context 'when :attribute_name option is given' do
              let(:options) { { attribute_name: true } }

              context 'when array option not given' do
                context 'when local_context option not given' do
                  it { is_expected.to eq 'text' }
                end

                context 'when local_context option given' do
                  let(:options) { { attribute_name: true, local_context: '/doc' } }
                  let(:xpath) { './text' }

                  it { is_expected.to eq 'text' }
                end
              end

              context 'when array option given' do
                let(:options) { { attribute_name: true, array: true } }

                it { is_expected.to eq ['text', 'text'] }
              end
            end

            context 'when :self_name option is given' do
              let(:options) { { self_name: true } }

              context 'when array option not given' do
                context 'when local_context option not given' do
                  it { is_expected.to eq 'text' }
                end

                context 'when local_context option given' do
                  let(:options) { { self_name: true, local_context: '/doc' } }
                  let(:xpath) { './text' }

                  it { is_expected.to eq 'text' }
                end
              end

              context 'when array option given' do
                let(:options) { { self_name: true, array: true } }

                it { is_expected.to eq ['text', 'text'] }
              end
            end

            context 'when no :*_name option is given' do
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
  attr_reader :string

  def initialize(string, options)
    @string = string
  end

  def evaluate
    string
  end

  def self.parsing_type?
    true
  end
end
