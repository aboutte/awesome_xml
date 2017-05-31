# frozen_string_literal: true

require File.expand_path("../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML::NodeXPath do
  let(:node_xpath) { described_class.new(node_name, options) }
  let(:node_name) { 'abcd' }
  let(:options) { {} }

  describe 'xpath' do
    subject { node_xpath.xpath }

    context 'when options[:xpath] is not set' do
      context 'when options[:array] is not set to true' do
        context 'when no other options are set' do
          it { is_expected.to eq './abcd' }
        end

        context 'when options[:element] is set' do
          context 'to true' do
            let(:options) { { element: true } }

            it { is_expected.to eq './abcd' }
          end

          context 'to a symbol or string' do
            let(:options) { { element: :dcba } }

            it { is_expected.to eq './dcba' }
          end
        end

        context 'when options[:attribute] is set' do
          context 'to true' do
            let(:options) { { attribute: true } }

            it { is_expected.to eq './@abcd' }
          end

          context 'to a symbol or string' do
            let(:options) { { attribute: :dcba } }

            it { is_expected.to eq './@dcba' }
          end
        end

        context 'when options[:self] is set' do
          context 'to true' do
            let(:options) { { self: true } }

            it { is_expected.to eq '.' }
          end

          context 'to a symbol or string' do
            let(:options) { { self: :dcba } }

            it { is_expected.to eq '.' }
          end
        end
      end

      context 'when options[:array] is set to true' do
        let(:options) { { array: true } }

        context 'when the node name is singular' do
          let(:node_name) { 'house' }
 
          context 'when no other options are set' do
            it { is_expected.to eq './house' }
          end

          context 'when options[:element] is set' do
            context 'to true' do
              let(:options) { { array: true, element: true } }

              it { is_expected.to eq './house' }
            end

            context 'to a symbol or string' do
              let(:options) { { array: true, element: :mice } }

              it { is_expected.to eq './mice' }
            end
          end

          context 'when options[:attribute] is set' do
            context 'to true' do
              let(:options) { { array: true, attribute: true } }

              it { is_expected.to eq './@house' }
            end

            context 'to a symbol or string' do
              let(:options) { { array: true, attribute: :mice } }

              it { is_expected.to eq './@mice' }
            end
          end

          context 'when options[:self] is set' do
            context 'to true' do
              let(:options) { { array: true, self: true } }

              it { is_expected.to eq '.' }
            end

            context 'to a symbol or string' do
              let(:options) { { array: true, self: :mice } }

              it { is_expected.to eq '.' }
            end
          end
        end

        context 'when the node name is plural' do
          let(:node_name) { 'mice' }
 
          context 'when no other options are set' do
            it { is_expected.to eq './mouse' }
          end

          context 'when options[:element] is set' do
            context 'to true' do
              let(:options) { { array: true, element: true } }

              it { is_expected.to eq './mouse' }
            end

            context 'to a symbol or string' do
              let(:options) { { array: true, element: :mice } }

              it { is_expected.to eq './mice' }
            end
          end

          context 'when options[:attribute] is set' do
            context 'to true' do
              let(:options) { { array: true, attribute: true } }

              it { is_expected.to eq './@mouse' }
            end

            context 'to a symbol or string' do
              let(:options) { { array: true, attribute: :mice } }

              it { is_expected.to eq './@mice' }
            end
          end

          context 'when options[:self] is set' do
            context 'to true' do
              let(:options) { { array: true, self: true } }

              it { is_expected.to eq '.' }
            end

            context 'to a symbol or string' do
              let(:options) { { array: true, self: :mice } }

              it { is_expected.to eq '.' }
            end
          end
        end
      end
    end

    context 'when options[:xpath] is set' do
      let(:options) { { xpath: '/xyz' } }

      it { is_expected.to eq '/xyz' }
    end
  end
end
