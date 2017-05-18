# frozen_string_literal: true

require File.expand_path("../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML do
  describe '#constant_node' do
    subject { root.new(anything).constant_node_name }

    let(:root) { RootWithConstantNode }

    class RootWithConstantNode < Struct.new(:data)
      include AwesomeXML::Root

      constant_node :constant_node_name, 'test test test'
    end

    it { is_expected.to eq 'test test test' }
  end

  describe '#method_node' do
    subject { root.new(anything).method_name }

    let(:root) { RootWithMethodNode }

    class RootWithMethodNode < Struct.new(:data)
      include AwesomeXML::Root

      method_node :method_name

      def method_name
        4 + 9
      end
    end

    it { is_expected.to eq 13 }
  end

  describe '#text_node' do
    subject { root.new(data).text_node_name }

    let(:data) { "<Some><Thing xyz='teeeest'/></Some>" }

    context 'when not passing a block' do
      let(:root) { RootWithTextNode }

      class RootWithTextNode < Struct.new(:data)
        include AwesomeXML::Root

        text_node :text_node_name, '*/Thing/@xyz'
      end

      it { is_expected.to eq 'teeeest' }
    end

    context 'when passing a block' do
      let(:root) { RootWithTextNodeAndBlock }

      class RootWithTextNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        text_node(:text_node_name, '*/Thing/@xyz') { |node| node.gsub('eeee', 'e') }
      end

      it('yields the result to the block') { is_expected.to eq 'test' }
    end
  end

  describe '#integer_node' do
    subject { root.new(data).integer_node_name }

    let(:data) { "<Some><Thing abc='321'/><Thing abc='123'/></Some>" }

    context 'when not passing a block' do
      let(:root) { RootWithIntegerNode }

      class RootWithIntegerNode < Struct.new(:data)
        include AwesomeXML::Root

        integer_node :integer_node_name, '//Thing/@abc'
      end

      it { is_expected.to eq 321 }
    end

    context 'when passing a block' do
      let(:root) { RootWithIntegerNodeAndBlock }

      class RootWithIntegerNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        integer_node(:integer_node_name, '//Thing/@abc') { |node| node * 100 }
      end

      it('yields the result to the block') { is_expected.to eq 32_100 }
    end
  end

  describe '#float_node' do
    subject { root.new(data).float_node_name }

    let(:data) { "<Some><Thing abc='321.0'/><Thing abc='123.4'/></Some>" }

    context 'when not passing a block' do
      let(:root) { RootWithFloatNode }

      class RootWithFloatNode < Struct.new(:data)
        include AwesomeXML::Root

        float_node :float_node_name, '//Thing/@abc'
      end

      it { is_expected.to eq 321.0 }
    end

    context 'when passing a block' do
      let(:root) { RootWithFloatNodeAndBlock }

      class RootWithFloatNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        float_node(:float_node_name, '//Thing/@abc') { |node| node * 100 }
      end

      it('yields the result to the block') { is_expected.to eq 32_100.0 }
    end
  end

  describe '#duration_node' do
    subject { root.new(data).duration_node_name }

    let(:data) { "<Some><Time abc='23.59'/></Some>" }

    context 'when not passing a block' do
      let(:root) { RootWithDurationNode }

      class RootWithDurationNode < Struct.new(:data)
        include AwesomeXML::Root

        duration_node :duration_node_name, '//Time/@abc', format: '{H}.{M}'
      end

      it { is_expected.to eq 23.hours + 59.minutes }
    end

    context 'when passing a block' do
      let(:root) { RootWithDurationNodeAndBlock }

      class RootWithDurationNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        duration_node(:duration_node_name, '//Time/@abc', format: '{H}.{M}') { |node| node + 1.minute }
      end

      it('yields the result to the block') { is_expected.to eq 24.hours }
    end
  end

  describe '#simple_node' do
    subject { root.new(data).simple_node_name }

    let(:data) { "<Some><Thing abc='321'/><Thing abc='123'/></Some>" }

    context 'when not passing a block' do
      let(:root) { RootWithSimpleNode }

      class RootWithSimpleNode < Struct.new(:data)
        include AwesomeXML::Root

        simple_node :integer, :simple_node_name, '//Thing/@abc'
      end

      it { is_expected.to eq 321 }
    end

    context 'when passing a block' do
      let(:root) { RootWithSimpleNodeAndBlock }

      class RootWithSimpleNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        simple_node(:integer, :simple_node_name, '//Thing/@abc') { |node| node * 100 }
      end

      it('yields the result to the block') { is_expected.to eq 32_100 }
    end

    context 'when passing an unknown type' do
      subject do
        class RootWithInvalidNode
          include AwesomeXML::Root

          simple_node(:abcdef, 'adfbd', 'adfvadf')
        end
      end

      specify { expect { subject }.to raise_error(AwesomeXML::BuilderMethods::UnknownNodeType) }
    end
  end

  describe '#text_array_node' do
    subject { root.new(data).things }

    let(:data) do
      "<Doc><Some><Thing abc='321'/><Thing abc='123'/></Some>\
      <SomeMore><Thing abc='987'/></SomeMore></Doc>"
    end

    context 'when not passing a block' do
      let(:root) { RootWithTextArrayNode }

      class RootWithTextArrayNode < Struct.new(:data)
        include AwesomeXML::Root

        text_array_node :things, "//Thing/@abc"
      end

      it { is_expected.to eq(%w(321 123 987)) }
    end

    context 'when passing a block' do
      let(:root) { RootWithTextArrayNodeAndBlock }

      class RootWithTextArrayNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        text_array_node(:things, "//Thing/@abc") { |node| node.reverse }
      end

      it('yields the result to the block') { is_expected.to eq(%w(987 123 321)) }
    end
  end

  describe '#integer_array_node' do
    subject { root.new(data).things }

    let(:data) do
      "<Doc><Some><Thing abc='321'/><Thing abc='123'/></Some>\
      <SomeMore><Thing abc='987'/></SomeMore></Doc>"
    end

    context 'when not passing a block' do
      let(:root) { RootWithIntegerArrayNode }

      class RootWithIntegerArrayNode < Struct.new(:data)
        include AwesomeXML::Root

        integer_array_node :things, "//Thing/@abc"
      end

      it { is_expected.to eq([321, 123, 987]) }
    end

    context 'when passing a block' do
      let(:root) { RootWithIntegerArrayNodeAndBlock }

      class RootWithIntegerArrayNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        integer_array_node(:things, "//Thing/@abc") { |node| node.reverse }
      end

      it('yields the result to the block') { is_expected.to eq([987, 123, 321]) }
    end
  end

  describe '#float_array_node' do
    subject { root.new(data).things }

    let(:data) do
      "<Doc><Some><Thing abc='321'/><Thing abc='123'/></Some>\
      <SomeMore><Thing abc='987'/></SomeMore></Doc>"
    end

    context 'when not passing a block' do
      let(:root) { RootWithFloatArrayNode }

      class RootWithFloatArrayNode < Struct.new(:data)
        include AwesomeXML::Root

        float_array_node :things, "//Thing/@abc"
      end

      it { is_expected.to eq([321.0, 123.0, 987.0]) }
    end

    context 'when passing a block' do
      let(:root) { RootWithFloatArrayNodeAndBlock }

      class RootWithFloatArrayNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        float_array_node(:things, "//Thing/@abc") { |node| node.reverse }
      end

      it('yields the result to the block') { is_expected.to eq([987.0, 123.0, 321.0]) }
    end
  end

  describe '#duration_array_node' do
    subject { root.new(data).times }

    let(:data) do
      "<Doc><Some><Time abc='1:60'/><Time abc='45:0'/></Some>\
      <SomeMore><Time abc='987:654'/></SomeMore></Doc>"
    end

    context 'when not passing a block' do
      let(:root) { RootWithDurationArrayNode }

      class RootWithDurationArrayNode < Struct.new(:data)
        include AwesomeXML::Root

        duration_array_node :times, "//Time/@abc", format: '{H}:{M}'
      end

      it { is_expected.to eq([2.hours, 45.hours, 987.hours + 654.minutes]) }
    end

    context 'when passing a block' do
      let(:root) { RootWithDurationArrayNodeAndBlock }

      class RootWithDurationArrayNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        duration_array_node(:times, "//Time/@abc", format: '{H}:{M}') { |node| node.reverse }
      end

      it('yields the result to the block') { is_expected.to eq([987.hours + 654.minutes, 45.hours, 2.hours]) }
    end
  end

  describe '#simple_array_node' do
    subject { root.new(data).things }

    let(:data) do
      "<Doc><Some times='10'><Thing abc='321'/><Thing abc='123'/></Some>\
      <SomeMore times='100'><Thing abc='987'/></SomeMore></Doc>"
    end

    context 'when not passing a block' do
      let(:root) { RootWithArrayNode }

      class RootWithArrayNode < Struct.new(:data)
        include AwesomeXML::Root

        simple_array_node :integer, :things, "//Thing/@abc"
      end

      it { is_expected.to eq([321, 123, 987]) }
    end

    context 'when passing a block' do
      let(:root) { RootWithArrayNodeAndBlock }

      class RootWithArrayNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        simple_array_node(:integer, :things, "//Thing/@abc") { |node| node.reverse }
      end

      it('yields the result to the block') { is_expected.to eq([987, 123, 321]) }
    end

    context 'when passing an unknown type' do
      subject do
        class RootWithInvalidArrayNode
          include AwesomeXML::Root

          simple_array_node(:abcdef, 'adfbd', 'adfvadf')
        end
      end

      specify { expect { subject }.to raise_error(AwesomeXML::BuilderMethods::UnknownNodeType) }
    end
  end

  describe '#child_node' do
    subject { root.new(data).thing }

    let(:data) { "<Some><Thing abc='321' real='no'/><Thing abc='123' real='yes'/></Some>" }

    context 'when not passing a block' do
      let(:root) { RootWithChildNode }

      class RootWithChildNode < Struct.new(:data)
        include AwesomeXML::Root

        child_node :thing, 'Thing', "Some/Thing[@real='yes']"

        class Thing
          include AwesomeXML::Child

          integer_node(:correct_integer_node, '@abc')
          integer_node(:incorrect_integer_node, 'Some/Thing/@abc')
        end
      end

      it { is_expected.to eq(correct_integer_node: 123, incorrect_integer_node: nil) }
    end

    context 'when passing a block' do
      let(:root) { RootWithChildNodeWithBlock }

      class RootWithChildNodeWithBlock < Struct.new(:data)
        include AwesomeXML::Root

        child_node(:thing, 'Thing', "Some/Thing[@real='yes']") { |node| [node, node] }

        class Thing
          include AwesomeXML::Child

          integer_node(:integer_node, '@abc')
        end
      end

      it('yields the result to the block') { is_expected.to eq([{ integer_node: 123 }, { integer_node: 123 }]) }
    end
  end

  describe '#child_array_node' do
    subject { root.new(data).things }

    let(:data) { "<Doc><Thing name='abc'>123</Thing><Thing name='bcd'>321</Thing></Doc>" }

    context 'when not passing a block' do
      let(:root) { RootWithChildArrayNode }

      class RootWithChildArrayNode < Struct.new(:data)
        include AwesomeXML::Root

        child_array_node :things, 'Child', "//Thing"

        class Child
          include AwesomeXML::Child

          text_node :name, '@name'
          integer_node :value, '.'
        end
      end

      it { is_expected.to eq([{ name: 'abc', value: 123 }, { name: 'bcd', value: 321 }]) }
    end

    context 'when passing a block' do
      let(:root) { RootWithChildArrayNodeAndBlock }

      class RootWithChildArrayNodeAndBlock < Struct.new(:data)
        include AwesomeXML::Root

        child_array_node(:things, 'Child', "//Thing") { |node| node.reverse }

        class Child
          include AwesomeXML::Child

          text_node :name, '@name'
          integer_node :value, '.'
        end
      end

      it 'yields the result to the block' do
        is_expected.to eq([{ name: 'bcd', value: 321 }, { name: 'abc', value: 123 }])
      end
    end
  end

  describe '.nodes' do
    subject { root.nodes }

    let(:root) { RootWithALotOfNodes }

    class RootWithALotOfNodes
      include AwesomeXML::Root

      constant_node :constant_node_name, 'test test test'
      constant_node :private_constant_node_name, 'test test test', private: true
      text_node :text_node_name, '*/Thing/@xyz'
      text_node :private_text_node_name, '*/Thing/@xyz', private: true
      integer_node :integer_node_name, '//Thing/@abc'
      integer_node :private_integer_node_name, '//Thing/@abc', private: true
      child_node :thing, 'Thing', "Some/Thing[@real='yes']"
      child_node :private_thing, 'Thing', "Some/Thing[@real='yes']", private: true
      simple_array_node(:integer, :things, "//Thing/@abc") { |node| node.reverse }
      simple_array_node(:integer, :things, "//Thing/@abc", private: true) { |node| node.reverse }

      class Thing
        include AwesomeXML::Child
      end
    end

    it 'only lists the ones not declared as private' do
      is_expected.to eq %i(constant_node_name text_node_name integer_node_name thing things)
    end
  end

  describe '.parse_type' do
    subject { root.parse_type(string, type, format) }

    let(:root) { MinimalRoot }
    let(:format) { nil }

    class MinimalRoot < Struct.new(:data)
      include AwesomeXML::Root
    end

    context 'parsing a string' do
      let(:type) { :text }
      let(:string) { 'abcdef' }

      it { is_expected.to eq string }

      context 'when string is nil' do
        let(:string) { nil }

        it { is_expected.to eq nil }
      end
    end

    context 'parsing an integer' do
      let(:type) { :integer }
      let(:string) { '15' }

      it { is_expected.to eq 15 }

      context 'when string is nil' do
        let(:string) { nil }

        it { is_expected.to eq nil }
      end

      context 'when string is empty' do
        let(:string) { '' }

        it { is_expected.to eq nil }
      end
    end

    context 'parsing a float' do
      let(:type) { :float }
      let(:string) { '15.5' }

      it { is_expected.to eq 15.5 }

      context 'when string is nil' do
        let(:string) { nil }

        it { is_expected.to eq nil }
      end

      context 'when string is empty' do
        let(:string) { '' }

        it { is_expected.to eq nil }
      end
    end

    context 'parsing a duration' do
      let(:type) { :duration }
      let(:string) { '12m34' }
      let(:format) { '{M}m{S}' }

      it { is_expected.to eq 12.minutes + 34.seconds }

      context 'when string is nil' do
        let(:string) { nil }

        it { is_expected.to eq nil }
      end

      context 'when string is empty' do
        let(:string) { '' }

        it { is_expected.to eq nil }
      end
    end

    context 'parsing an unknown type' do
      let(:type) { :xxx }
      let(:string) { '15.5' }

      it { is_expected.to eq nil }
    end
  end

  describe '#to_hash' do
    subject { root.new(data).to_hash }

    let(:root) { AnotherRootWithALotOfNodes }
    let(:data) do
      "<doc title='Poop'><things><thing s='a'>2</thing>\
      <thing s='b'>20</thing></things><stuff title='peep'>STUFF</stuff></doc>"
    end

    class AnotherRootWithALotOfNodes < Struct.new(:data)
      include AwesomeXML::Root

      text_node :title, 'doc/@title'
      integer_array_node :thing_values, 'doc/things/thing'
      child_array_node :things, 'Thing', 'doc/things/thing'
      child_node :stuff, 'Stuff', 'doc/stuff'

      class Thing
        include AwesomeXML::Child

        text_node :s, '@s'
        integer_node :value, '.'
      end

      class Stuff
        include AwesomeXML::Child

        text_node :title, '@title'
        text_node :text, '.'
      end
    end

    it do
      is_expected.to eq(
        title: 'Poop',
        thing_values: [2, 20],
        things: [{ s: 'a', value: 2 }, { s: 'b', value: 20 }],
        stuff: { title: 'peep', text: 'STUFF' }
      )
    end
  end
end
