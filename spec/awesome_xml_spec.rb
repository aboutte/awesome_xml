# frozen_string_literal: true

require File.expand_path("../../lib/awesome_xml.rb", __FILE__)

RSpec.describe AwesomeXML do
  describe '.constant_node' do
    subject { awesome_class.parse(nil).constant }

    let(:awesome_class) { ClassWithConstantNode }

    class ClassWithConstantNode
      include AwesomeXML

      constant_node :constant, 'test test test'
    end

    it { is_expected.to eq 'test test test' }
  end

  describe '.method_node' do
    subject { awesome_class.parse(nil).method }

    let(:awesome_class) { ClassWithMethodNode }

    class ClassWithMethodNode
      include AwesomeXML

      method_node :method

      def method
        4 + 9
      end
    end

    it { is_expected.to eq 13 }
  end

  describe '.set_context' do
    subject { awesome_class.parse(xml).to_hash }

    let(:xml) { "<doc><some><thing>1234</thing></some></doc>" }
    let(:awesome_class) { ClassWithSetContext }

    class ClassWithSetContext
      include AwesomeXML

      set_context 'doc/some'
      node :thing, :text
    end

    it { is_expected.to eq(thing: '1234') }
  end

  describe '.with_context' do
    subject { awesome_class.parse(xml).to_hash }

    let(:xml) { "<doc><some><thing>1234</thing></some></doc>" }
    let(:awesome_class) { ClassWithWithContextBlock }

    class ClassWithWithContextBlock
      include AwesomeXML

      with_context '/doc/some' do
        node :thing, :text
      end
      with_context '/doc' do
        node :other_thing, :text, xpath: 'some/thing'
      end
    end

    it { is_expected.to eq(thing: '1234', other_thing: '1234') }
  end

  describe '.context' do
    subject { awesome_class.context }

    let(:awesome_class) { ClassWithContext }

    class ClassWithContext
      include AwesomeXML

      set_context 'doc/some'
      node :thing, :text
    end

    it { is_expected.to eq 'doc/some' }
  end

  describe '.node' do
    subject { awesome_class.parse(xml).thing }

    let(:xml) { "<some><thing>1234</thing></some>" }

    context 'when passing type text' do
      let(:awesome_class) { ClassWithTextNode }

      class ClassWithTextNode
        include AwesomeXML

        set_context 'some'
        node :thing, :text
      end

      it { is_expected.to eq '1234' }
    end

    context 'when passing type integer' do
      let(:awesome_class) { ClassWithIntegerNode }

      class ClassWithIntegerNode
        include AwesomeXML

        set_context 'some'
        node :thing, :integer
      end

      it { is_expected.to eq 1234 }
    end

    context 'when passing type float' do
      let(:awesome_class) { ClassWithFloatNode }

      class ClassWithFloatNode
        include AwesomeXML

        set_context 'some'
        node :thing, :float
      end

      it { is_expected.to eq 1234.0 }
    end

    context 'when passing type duration' do
      context 'when passing a format option' do
        let(:awesome_class) { ClassWithDurationNode }

        class ClassWithDurationNode
          include AwesomeXML

          set_context 'some'
          node :thing, :duration, format: '{H2}{M}'
        end

        it { is_expected.to eq 754.minutes }
      end

      context 'when not passing a format option' do
        let(:awesome_class) { ClassWithDurationNodeNoFormat }

        class ClassWithDurationNodeNoFormat
          include AwesomeXML

          set_context 'some'
          node :thing, :duration
        end

        specify { expect { subject }.to raise_error AwesomeXML::Duration::NoFormatProvided }
      end
    end

    context 'when passing a class as type' do
      let(:awesome_class) { ClassWithNodeFromClass }

      class ClassWithNodeFromClass
        include AwesomeXML

        class Thing
          include AwesomeXML

          node :value, :integer, tag_type: :value
        end

        set_context 'some'
        node :thing, Thing
      end

      it { is_expected.to eq(value: 1234) }
    end

    context 'when passing a class name as type' do
      let(:awesome_class) { ClassWithNodeFromClassName }

      class ClassWithNodeFromClassName
        include AwesomeXML

        set_context 'some'
        node :thing, 'Thing'

        class Thing
          include AwesomeXML

          node :value, :integer, tag_type: :value
        end
      end

      it { is_expected.to eq(value: 1234) }
    end

    context 'when passing an unknown type' do
      let(:awesome_class) { ClassWithInvalidNode }

      class ClassWithInvalidNode
        include AwesomeXML

        set_context 'some'
        node :thing, :adfbd
      end

      specify { expect { subject }.to raise_error(AwesomeXML::Type::UnknownNodeType) }
    end

    context 'when passing a block' do
      context 'vanilla' do
        let(:awesome_class) { ClassWithBlock }

        class ClassWithBlock
          include AwesomeXML

          set_context 'some'
          node(:thing, :integer) { |node| node * 100 }
        end

        it { is_expected.to eq 123_400 }
      end

      context 'that accesses instance methods' do
        let(:xml) { "<some><thing multi='10'>1234</thing></some>" }
        let(:awesome_class) { ClassWithBlockReferencingInstance }

        class ClassWithBlockReferencingInstance
          include AwesomeXML

          set_context 'some'
          node :multi, :integer, xpath: './thing/@multi'
          node(:thing, :integer) { |node, instance| node * instance.multi }
        end

        it { is_expected.to eq 12_340 }
      end
    end

    context 'when overriding the attribute reader' do
      context 'vanilla' do
        let(:awesome_class) { ClassWithOverridingMethod }

        class ClassWithOverridingMethod
          include AwesomeXML

          set_context 'some'
          node :thing, :integer

          def thing
            @thing * 100
          end
        end

        it('returns the modified value') { is_expected.to eq 123_400 }
      end

      context 'and accessing other nodes from there' do
        let(:xml) { "<some><thing multi='10'>1234</thing></some>" }
        let(:awesome_class) { ClassWithOverridingMethodAndNodeAccess }

        class ClassWithOverridingMethodAndNodeAccess
          include AwesomeXML

          set_context 'some'
          node :thing, :integer
          node :multi, :integer, xpath: './thing/@multi'

          def thing
            @thing * multi
          end
        end

        it('returns the modified value') { is_expected.to eq 12_340 }
      end
    end

    context 'when passing array as an option' do
      subject { awesome_class.parse(xml).things }

      let(:xml) do
        "<some><thing>123</thing><thing>456</thing></some>"
      end
      let(:awesome_class) { ClassWithArrayNode }

      class ClassWithArrayNode
        include AwesomeXML

        set_context 'some'
        node :things, :integer, array: true
      end

      it { is_expected.to eq([123, 456]) }
    end

    context 'when not passing in a specific xpath' do
      context 'when passing tag_type in options' do
        context 'when passing tag_type attribute' do
          let(:xml) do
            "<some><item thing='Title'/></some>"
          end
          let(:awesome_class) { ClassWithAttributeNode }

          class ClassWithAttributeNode
            include AwesomeXML

            set_context 'some/item'
            node :thing, :text, tag_type: :attribute
          end

          it { is_expected.to eq('Title') }
        end

        context 'when passing tag_type value' do
          let(:xml) do
            "<some>Content</some>"
          end
          let(:awesome_class) { ClassWithValueNode }

          class ClassWithValueNode
            include AwesomeXML

            set_context 'some'
            node :thing, :text, tag_type: :value
          end

          it { is_expected.to eq('Content') }
        end
      end
    end

    context 'when passing in a look for option' do
      let(:xml) { "<some><Thing>1234</Thing></some>" }
      let(:awesome_class) { ClassWithLookFor }

      class ClassWithLookFor
        include AwesomeXML

        set_context 'some'
        node :thing, :text, look_for: 'Thing'
      end

      it { is_expected.to eq '1234' }
    end

    context 'when passing in a specific xpath' do
      let(:xml) { "<some><Thing real='n'>1234</Thing><Thing real='y'>4321</Thing></some>" }
      let(:awesome_class) { ClassWithXPath }

      class ClassWithXPath
        include AwesomeXML

        set_context 'some'
        node :thing, :text, xpath: "./Thing[@real='y']"
      end

      it { is_expected.to eq '4321' }
    end

    context 'when passing default value' do
      let(:awesome_class) { ClassWithDefault }

      class ClassWithDefault
        include AwesomeXML

        set_context 'some'
        node :thing, :text, default: '1900'
      end

      context 'but value could be parsed' do
        context 'and it is not empty' do
          let(:xml) { "<some><thing>1234</thing></some>" }

          it { is_expected.to eq '1234' }
        end

        context 'and it is empty' do
          let(:xml) { "<some><thing></thing></some>" }

          it { is_expected.to eq '' }
        end
      end

      context 'and value could not be parsed' do
        let(:xml) { "<some></some>" }

        it { is_expected.to eq '1900' }
      end
    end

    context 'when passing default value for empty string' do
      let(:awesome_class) { ClassWithDefaultForEmpty }

      class ClassWithDefaultForEmpty
        include AwesomeXML

        set_context 'some'
        node :thing, :text, default_empty: '1900'
      end

      context 'but value could be parsed' do
        context 'and it is not empty' do
          let(:xml) { "<some><thing>1234</thing></some>" }

          it { is_expected.to eq '1234' }
        end

        context 'and it is empty' do
          let(:xml) { "<some><thing></thing></some>" }

          it { is_expected.to eq '1900' }
        end
      end

      context 'and value could not be parsed' do
        let(:xml) { "<some></some>" }

        it { is_expected.to eq nil }
      end
    end
  end

  describe '#parent_node' do
    subject { awesome_class.parse(xml).to_hash }

    let(:xml) { "<some multi='10'><thing>1234</thing></some>" }
    let(:awesome_class) { ClassWithChildThatReachesUp }

    class ClassWithChildThatReachesUp
      include AwesomeXML

      set_context 'some'
      node :multi, :integer, tag_type: :attribute
      node :thing, 'Thing'
      
      class Thing
        include AwesomeXML

        node :value, :integer, tag_type: :value

        def value
          @value * parent_node.multi
        end
      end
    end

    it { is_expected.to eq(multi: 10, thing: { value: 12_340 }) }
  end

  describe '.nodes' do
    subject { awesome_class.nodes }

    let(:awesome_class) { ClassWithALotOfNodes }

    class ClassWithALotOfNodes
      include AwesomeXML

      constant_node :constant_node_name, 'xyz'
      constant_node :private_constant_node_name, :method, private: true
      method_node :method_node_name
      node :text_node_name, :text
      node :private_text_node_name, :text, private: true
      node :integer_node_name, :integer
      node :private_integer_node_name, :integer, private: true
      node :thing, 'Thing'
      node :private_thing, 'Thing', private: true
      node(:things, :integer, array: true) { |node| node.reverse }
      node(:private_things, :integer, array: true, private: true) { |node| node.reverse }

      class Thing
        include AwesomeXML
      end
    end

    it 'lists all nodes, even private ones' do
      is_expected.to eq %i(
        constant_node_name
        private_constant_node_name
        method_node_name
        text_node_name
        private_text_node_name
        integer_node_name
        private_integer_node_name
        thing
        private_thing
        things
        private_things
      )
    end
  end

  describe '.public_nodes' do
    subject { awesome_class.public_nodes }

    let(:awesome_class) { ClassWithALotOfNodes }

    it 'only lists the ones not declared as private' do
      is_expected.to eq %i(constant_node_name method_node_name text_node_name integer_node_name thing things)
    end
  end

  describe '#to_hash' do
    subject { awesome_class.parse(xml).to_hash }

    context 'when passing nil xml' do
      let(:xml) { nil }
      let(:awesome_class) { ClassWithForNilXML }

      class ClassWithForNilXML
        include AwesomeXML

        set_context 'some'
        node :thing, :text
        node :things, :text, array: true
      end

      it { is_expected.to eq(thing: nil, things: []) }
    end

    context 'when passing xml' do
      let(:awesome_class) { AnotherClassWithALotOfNodes }
      let(:xml) do
        "<doc title='Poop'><things><thing s='a' t=''>2</thing>\
        <thing s='b' t='00d2h17m'>20.2</thing></things><stuff>STUFF</stuff></doc>"
      end

      class AnotherClassWithALotOfNodes
        include AwesomeXML

        set_context 'doc'
        node :title, :text, tag_type: :attribute
        with_context 'things/thing' do
          node :thing_names, :text, array: true, tag_type: :attribute, look_for: 's'
          node :thing_integer_values, :integer, array: true, tag_type: :value
          node :thing_values, :float, array: true, tag_type: :value
          node :thing_durations, :duration, xpath: './@t', array: true, format: '{D}d{H}h{M}m', default_empty: nil
        end
        node :things, 'Thing', xpath: 'things/thing', array: true
        node :stuff, 'Stuff'

        class Thing
          include AwesomeXML

          node :s, :text, tag_type: :attribute
          node :integer_value, :integer, tag_type: :value
          node :value, :float, tag_type: :value
          node :duration, :duration, tag_type: :attribute, look_for: 't', format: '{D}d{H}h{M}m', default_empty: 1.hour
        end

        class Stuff
          include AwesomeXML

          node :text, :text, tag_type: :value
        end
      end

      let(:expected_hash) do
        {
          title: 'Poop',
          thing_names: ['a', 'b'],
          thing_integer_values: [2, 20],
          thing_values: [2.0, 20.2],
          thing_durations: [nil, 137.minutes],
          things: [
            {
              s: 'a',
              integer_value: 2,
              value: 2.0,
              duration: 1.hour
            },
            {
              s: 'b',
              integer_value: 20,
              value: 20.2,
              duration: 137.minutes
            }
          ],
          stuff: { text: 'STUFF' }
        }
      end

      it do
        is_expected.to eq expected_hash
      end

      describe '#evaluate' do
        subject { awesome_class.parse(xml).evaluate }

        it do
          is_expected.to eq expected_hash
        end
      end
    end
  end
end
