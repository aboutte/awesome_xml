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
        context 'when options[:look_for] is not set' do
          context 'when options[:tag_type] is not set' do
            it { is_expected.to eq './abcd' }
          end

          context 'when options[:tag_type] is set to :attribute' do
            let(:options) { { tag_type: :attribute } }

            it { is_expected.to eq './@abcd' }
          end

          context 'when options[:tag_type] is set to :value' do
            let(:options) { { tag_type: :value } }

            it { is_expected.to eq '.' }
          end

          context 'when options[:tag_type] is set to something random' do
            let(:options) { { tag_type: :something_random } }

            it { is_expected.to eq './abcd' }
          end
        end

        context 'when options[:look_for] is set' do
          let(:options) { { look_for: 'dcba' } }

          context 'when options[:tag_type] is not set' do
            it { is_expected.to eq './dcba' }
          end

          context 'when options[:tag_type] is set to :attribute' do
            let(:options) { { look_for: 'dcba', tag_type: :attribute } }

            it { is_expected.to eq './@dcba' }
          end

          context 'when options[:tag_type] is set to :value' do
            let(:options) { { look_for: 'dcba', tag_type: :value } }

            it { is_expected.to eq '.' }
          end

          context 'when options[:tag_type] is set to something random' do
            let(:options) { { look_for: 'dcba', tag_type: :something_random } }

            it { is_expected.to eq './dcba' }
          end
        end
      end

      context 'when options[:array] is set to true' do
        let(:options) { { array: true } }

        context 'when the node name is singular' do
          let(:node_name) { 'house' }
 
          context 'when options[:look_for] is not set' do
            context 'when options[:tag_type] is not set' do
              it { is_expected.to eq './house' }
            end

            context 'when options[:tag_type] is set to :attribute' do
              let(:options) { { array: true, tag_type: :attribute } }

              it { is_expected.to eq './@house' }
            end

            context 'when options[:tag_type] is set to :value' do
              let(:options) { { array: true, tag_type: :value } }

              it { is_expected.to eq '.' }
            end

            context 'when options[:tag_type] is set to something random' do
              let(:options) { { array: true, tag_type: :something_random } }

              it { is_expected.to eq './house' }
            end
          end

          context 'when options[:look_for] is set' do
            let(:options) { { array: true, look_for: 'mouse' } }

            context 'when options[:tag_type] is not set' do
              it { is_expected.to eq './mouse' }
            end

            context 'when options[:tag_type] is set to :attribute' do
              let(:options) { { array: true, look_for: 'mouse', tag_type: :attribute } }

              it { is_expected.to eq './@mouse' }
            end

            context 'when options[:tag_type] is set to :value' do
              let(:options) { { array: true, look_for: 'mouse', tag_type: :value } }

              it { is_expected.to eq '.' }
            end

            context 'when options[:tag_type] is set to something random' do
              let(:options) { { array: true, look_for: 'mouse', tag_type: :something_random } }

              it { is_expected.to eq './mouse' }
            end
          end
        end

        context 'when the node name is plural' do
          let(:node_name) { 'mice' }
 
          context 'when options[:look_for] is not set' do
            context 'when options[:tag_type] is not set' do
              it { is_expected.to eq './mouse' }
            end

            context 'when options[:tag_type] is set to :attribute' do
              let(:options) { { array: true, tag_type: :attribute } }

              it { is_expected.to eq './@mouse' }
            end

            context 'when options[:tag_type] is set to :value' do
              let(:options) { { array: true, tag_type: :value } }

              it { is_expected.to eq '.' }
            end

            context 'when options[:tag_type] is set to something random' do
              let(:options) { { array: true, tag_type: :something_random } }

              it { is_expected.to eq './mouse' }
            end
          end

          context 'when options[:look_for] is set' do
            let(:options) { { array: true, look_for: 'houses' } }

            context 'when options[:tag_type] is not set' do
              it { is_expected.to eq './houses' }
            end

            context 'when options[:tag_type] is set to :attribute' do
              let(:options) { { array: true, look_for: 'houses', tag_type: :attribute } }

              it { is_expected.to eq './@houses' }
            end

            context 'when options[:tag_type] is set to :value' do
              let(:options) { { array: true, look_for: 'houses', tag_type: :value } }

              it { is_expected.to eq '.' }
            end

            context 'when options[:tag_type] is set to something random' do
              let(:options) { { array: true, look_for: 'houses', tag_type: :something_random } }

              it { is_expected.to eq './houses' }
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
