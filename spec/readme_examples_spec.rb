# frozen_string_literal: true

require File.expand_path("../../lib/awesome-xml.rb", __FILE__)

RSpec.describe 'README examples' do
  let(:instance) { example_class.parse(xml) }

  describe 'Create your first awesome node' do
    subject { instance.title }

    let(:xml) { '<document><title>This is a document.</title></document>' }

    context 'first example' do
      let(:example_class) { MyDocument1 }

      class MyDocument1
        include AwesomeXML

        set_context 'document'
        node :title, :text
      end

      it { is_expected.to eq 'This is a document.' }
    end

    context 'second example' do
      let(:example_class) { MyDocument2 }

      class MyDocument2
        include AwesomeXML

        node :title, :text, xpath: 'document/title'
      end

      it { is_expected.to eq 'This is a document.' }
    end

    context 'third example' do
      let(:example_class) { MyDocument3 }

      class MyDocument3
        include AwesomeXML

        with_context 'document' do
          node :title, :text
        end
      end

      it { is_expected.to eq 'This is a document.' }
    end

    context 'fourth example' do
      let(:example_class) { MyDocument4 }

      class MyDocument4
        include AwesomeXML

        set_context 'document/title'
        node :title, :text, self: true
      end

      it { is_expected.to eq 'This is a document.' }
    end
  end

  describe 'Attributes, elements and `self`' do
    subject { instance.title }

    let(:xml) { "<document title='This is a document.'/>" }
    let(:example_class) { MyDocument5 }

    class MyDocument5
      include AwesomeXML

      set_context 'document'
      node :title, :text, attribute: true
    end

    it { is_expected.to eq 'This is a document.' }
  end

  describe 'Method nodes' do
    subject { instance.to_hash }

    let(:xml) { '<document><title>This is a document.</title></document>' }
    let(:example_class) { MyDocument6 }

    class MyDocument6
      include AwesomeXML

      set_context 'document'
      node :title, :text
      method_node :reversed_title

      def reversed_title
        title.reverse
      end
    end

    it { is_expected.to eq(title: "This is a document.", reversed_title: ".tnemucod a si sihT") }
  end

  describe 'Child nodes' do
    subject { instance.to_hash }

    let(:xml) { "<document><title>This is a document.</title><item ref='123'><owner>John Doe</owner></item></document>" }

    context 'first example' do
      let(:example_class) { MyDocument7 }

      class MyDocument7
        include AwesomeXML

        set_context 'document'
        node :title, :text
        node :item, 'Item'

        class Item
          include AwesomeXML

          node :reference, :integer, attribute: :ref
          node :owner, :text
        end
      end

      it { is_expected.to eq(title: "This is a document.", item: { reference: 123, owner: 'John Doe' }) }
    end

    context 'second example' do
      let(:example_class) { MyDocument8 }

      class MyDocument8
        include AwesomeXML

        class Item
          include AwesomeXML

          node :reference, :integer, attribute: :ref
          node :owner, :text
        end

        set_context 'document'
        node :title, :text
        node :item, Item
      end

      it { is_expected.to eq(title: "This is a document.", item: { reference: 123, owner: 'John Doe' }) }
    end
  end

  describe 'Array nodes' do
    subject { instance.to_hash }

    let(:xml) { "<document><item ref='123'/><item ref='456'/><item ref='789'/></document>" }

    context 'first example' do
      let(:example_class) { MyDocument9 }

      class MyDocument9
        include AwesomeXML

        set_context 'document/item'
        node :refs, :integer, attribute: true, array: true
      end

      it { is_expected.to eq(refs: [123, 456, 789]) }
    end

    context 'first example' do
      let(:example_class) { MyDocument10 }

      class MyDocument10
        include AwesomeXML

        set_context 'document'
        node :items, 'Item', array: true

        class Item
          include AwesomeXML

          node :ref, :integer, attribute: true
        end
      end

      it { is_expected.to eq(items: [{ ref: 123 }, { ref: 456 }, { ref: 789 }]) }
    end
  end

  describe 'Passing blocks' do
    subject { instance.to_hash }

    context 'first example' do
      let(:xml) { "<document><item index='1'/><item index='2'/><item index='3'/></document>" }
      let(:example_class) { MyDocument11 }

      class MyDocument11
        include AwesomeXML

        set_context 'document'
        node(:items, :integer, array: true, xpath: './item/@index') do |values|
          values.map { |value| value - 1 }
        end
      end

      it { is_expected.to eq(items: [0, 1, 2]) }
    end

    context 'second example' do
      let(:xml) { "<document><items multiplicator='100'><item value='1'/><item value='2'/><item value='3'/></items></document>" }
      let(:example_class) { MyDocument12 }

      class MyDocument12
        include AwesomeXML

        set_context 'document/items'
        node :multiplicator, :integer, attribute: true
        node(:item_values, :integer, array: :true, xpath: './item/@value') do |values, instance|
          values.map { |value| value * instance.multiplicator }
        end
      end

      it { is_expected.to eq(multiplicator: 100, item_values: [100, 200, 300]) }
    end
  end

  describe 'Overwriting attribute readers' do
    subject { instance.to_hash }

    let(:xml) { "<document><items multiplicator='100'><item value='1'/><item value='2'/><item value='3'/></items></document>" }
    let(:example_class) { MyDocument13 }

    class MyDocument13
      include AwesomeXML

      set_context 'document/items'
      node :multiplicator, :integer, attribute: true
      node :item_values, :integer, array: :true, xpath: './item/@value'

      def item_values
        @item_values.map { |value| value * multiplicator }
      end
    end

    it { is_expected.to eq(multiplicator: 100, item_values: [100, 200, 300]) }
  end

  describe '#parent_node' do
    subject { instance.to_hash }

    let(:xml) { "<document><items multiplicator='100'><item value='1'/><item value='2'/><item value='3'/></items></document>" }

    context 'first example' do
      let(:example_class) { MyDocument14 }

      class MyDocument14
        include AwesomeXML

        set_context 'document/items'
        node :items, 'Item', array: true

        class Item
          include AwesomeXML

          node :multiplicator, :integer, xpath: '../@multiplicator', private: true
          node :value, :integer, attribute: true

          def value
            @value * multiplicator
          end
        end
      end

      it { is_expected.to eq(items: [{value: 100}, {value: 200}, {value: 300}]) }
    end

    context 'second example' do
      let(:example_class) { MyDocument15 }

      class MyDocument15
        include AwesomeXML

        set_context 'document/items'
        node :multiplicator, :integer, attribute: true, private: true
        node :items, 'Item', array: true

        class Item
          include AwesomeXML

          node :value, :integer, attribute: true

          def value
            @value * parent_node.multiplicator
          end
        end
      end

      it { is_expected.to eq(items: [{value: 100}, {value: 200}, {value: 300}]) }
    end
  end

  describe ':private' do
    subject { instance.to_hash }

    let(:xml) { "<document><items multiplicator='100'><item value='1'/><item value='2'/><item value='3'/></items></document>" }
    let(:example_class) { MyDocument16 }

    class MyDocument16
      include AwesomeXML

      set_context 'document/items'
      node :multiplicator, :integer, attribute: true, private: true
      node :item_values, :integer, array: :true, xpath: './item/@value'

      def item_values
        @item_values.map { |value| value * multiplicator }
      end
    end

    it { is_expected.to eq(item_values: [100, 200, 300]) }
  end
end
