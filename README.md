# AwesomeXML

AwesomeXML is an XML mapping library that lets your Ruby classes parse arbitrary data from XML documents into a hash.
The hash can be structured completely freely. The parsing itself is based on [Nokogiri](https://github.com/sparklemotion/nokogiri).
The concept is very similar to that of [happymapper](https://github.com/dam5s/happymapper).

## Include it

Include `AwesomeXML` in any class you want to have all the capabilities this gem provides to you.

```ruby
class MyDocument
  include AwesomeXML
end
```

## Feed it

Your class will now have a `.parse` class method which takes in a single argument containing a string
representing an XML document. It returns an instance of your class. Like this:

```ruby
my_document = MyDocument.parse('<document><title>This is a document.</title></document>')
=> #<MyDocument:0x007fc57d239520 @xml=#<Nokogiri::XML::Document:0x3fe2be91ca54 name="document" children=[#<Nokogiri::XML::Element:0x3fe2be91c70c name="document" children=[#<Nokogiri::XML::Element:0x3fe2be91c52c name="title" children=[#<Nokogiri::XML::Text:0x3fe2be91c34c "This is a document.">]>]>]>, @parent_node=nil>
```

## Create your first awesome node

Let's say you have this XML document and you want to parse the content of the `<title></title>` tag.

```xml
<document>
  <title>This is a document.</title>
</document>
```

The `AwesomeXML` module defines several class methods on your class that that help you with that.
The most basic one is the `.node` method.
Its arguments are
  - a symbol, which will be the name of your node.
  - the type which the parser will assume the parsed value has
  - an options hash (optional)

The type can either be a native type given in the form of a symbol (currently supported are `:text`,
`:integer`, `:float`, `:duration` and `:date_time`), or a custom class. You can also pass in a string containing
a class name in case the class constant is not yet defined at the time you run the `.node` method.
More about that later.

Let's try it!

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document'
  node :title, :text
end
```

Notice we needed to set a context node `'document'` so the `title` node could be found. `.set_context` takes an XPath
and sets the current node for the whole class. There's a few other ways you can achievement the same thing as above.
For example by passing in an explicit XPath.

```ruby
class MyDocument
  include AwesomeXML

  node :title, :text, xpath: 'document/title'
end
```

If you don't pass an XPath (like in the very first example), the default is assumed, which is `"./#{name_of_you_node}"`.
Or, if you don't want to set the context node for the whole class, you can use `.with_context`, which takes a block:

```ruby
class MyDocument
  include AwesomeXML

  with_context 'document' do
    node :title, :text
  end
end
```

All of these make a few things possible. Firstly, after calling `MyDocument.parse(xml_string)`, you can access
an attribute reader method with the name of your node (`title`). It contains the value parsed from your XML document.

```ruby
my_document.title
=> "This is a document."
```

Secondly, it changes the result of the `#to_hash` method of your class. More about that later.

## Attributes, elements and `self`

Let's say your XML document has important data hidden in the attributes of tags:

```xml
<document title='This is a document.'/>
```

One way to do it is to pass the option `attribute: true` to your node:

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document'
  node :title, :text, attribute: true
end
```

This is the same as passing an explicit XPath `"./@#{name_of_you_node}"`.
Instead of just `true`, you can pass in a symbol (or string) to the `:attribute` option that will then be used to
build the XPath to your node, instead of using the node name. Use this whenever you want your nodes
to be named differently than in the XML document.

This is also true for the other two types of nodes: elements and `self`. By default, `AwesomeXML` will look for
elements, so passing the option `element: true` will do nothing. But you can use the option like `:attribute`, in
that you can pass something else than `true` to tell the parser to look for an element with a different name.

The last type of node is `self`. Pass in `self: true` if you want to access the content of the current context
node itself. This is equivalent to passing in `xpath: '.'`. Changing the option value will do nothing.

## Method nodes

If you want, you can define your node in a method. Like this:

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document'
  node :title, :text
  method_node :reversed_title

  def reversed_title
    title.reverse
  end
end
```

You might say, ok, that's useless. I don't need to have the node define my `#reversed_title` method for me,
I'm doing that myself already! And you would be correct. There's one side effect, though, related to
the following awesome method that is provided to you:

## `#to_hash`

Including `AwesomeXML` will define the method `#to_hash` on your class. It traverses all the nodes
you defined in your class (including the ones declared with `.method_node`) and returns values in a hash
that follows the structure you defined. Let's take the example from the section above. Then, `#to_hash`
would do the following:

```ruby
my_document.to_hash
=> {:title=>"This is a document.", :reversed_title=>".tnemucod a si sihT"}
```

Let's step it up a little.

## Child nodes

Let's say you have a slightly more complicated XML document. Baby steps.

```xml
<document>
  <title>This is a document.</title>
  <item ref='123'>
    <owner>John Doe</owner>
  </item>
</document>
```

If you want your parsed hash to look like this:
```ruby
{ title: "This is a document.", item: { reference: 123, owner: 'John Doe' } }
```
You can do that by creating a node of the type of another class that also includes `AwesomeXML`.

```ruby
class MyDocument
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
```

Easy! You might have noticed that the context node for the `Item` class is automatically set. No need
to call `.set_context` except you want to override the default, of course.

If you want, you can also pass in the class itself instead of a string with the class name.
Just make sure that it is defined before you use it in your `.node` method! Like this:

```ruby
class MyDocument
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
```

## Array nodes

What if you have more than one `<item/>`? Say your XML document looks like this:

```xml
<document>
  <item ref='123'/>
  <item ref='456'/>
  <item ref='789'/>
</document>
```

And you want your parsed hash to look like this:

```ruby
{ refs: [123, 456, 789] }
```

Fret no more, just use the option `array: true`:

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document/item'
  node :refs, :integer, attribute: true, array: true
end
```

Pretty self-explanatory, right? `AwesomeXML` even singularizes your node name automatically!

Okay, you say, that's a very simple array, indeed. What if I want an array of hashes? Like so:
```ruby
{ items: [{ ref: 123 }, { ref: 456 }, { ref: 789 }] }
```

Just combine the two things we last learned:

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document'
  node :items, 'Item', array: true

  class Item
    include AwesomeXML

    node :ref, :integer, attribute: true
  end
end
```

Awesome, right? You've got a few more notches you can kick it up, though.

## Passing blocks

That's right, you can pass blocks. It's actually very simple. All `*_node` methods (except `.method_node`
and `.constant_node`) define instance methods that yield their result to the block you specify. This lets you
do pretty much anything you want. Let's say you don't like the way the items are numbered in your XML document:

```xml
<document>
  <item index='1'/>
  <item index='2'/>
  <item index='3'/>
</document>
```

Yuck. Let's fix that:

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document'
  node(:items, :integer, array: true, xpath: './item/@index') do |values|
    values.map { |value| value - 1 }
  end
end

my_document.to_hash
=> {:items=>[0, 1, 2]}

```

That's better. Note that array nodes yield the whole array to the block and not an `Enumerator`.

There's another twist to this block passing, though. AwesomeXML also yields the instance of your class
to the block so you can actually access other nodes inside the block! Let's see it in action.

Your XML data:
```xml
<document>
  <items multiplicator='100'>
    <item value='1'/>
    <item value='2'/>
    <item value='3'/>
  </items>
</document>
```

Your `AwesomeXML` class:

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document/items'
  node :multiplicator, :integer, attribute: true
  node(:item_values, :integer, array: :true, xpath: './item/@value') do |values, instance|
    values.map { |value| value * instance.multiplicator }
  end
end

my_document.to_hash
=> {:multiplicator=>100, :item_values=>[100, 200, 300]}
```

## Overwriting attribute readers

You can achieve the same effect as passing blocks by redefining the attribute accessors that `AwesomeXML`
usually defines for you. Arguably, this is the more elegant method, although you might prefer the block
syntax's brevity for more simple operations.

Let's see how the example from above would look in this style:

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document/items'
  node :multiplicator, :integer, attribute: true
  node :item_values, :integer, array: :true, xpath: './item/@value'

  def item_values
    @item_values.map { |value| value * multiplicator }
  end
end
```

## `#parent_node`

This method is available on all class instances including the `AwesomeXML` module. It returns the
instance of the class it was initialized from. Let's see how that can be useful. Let's again use
the XML document from the above two examples.

```xml
<document>
  <items multiplicator='100'>
    <item value='1'/>
    <item value='2'/>
    <item value='3'/>
  </items>
</document>
```

This time, you want each `<item/>` to be represented by its own hash. Like this:
```ruby
my_document.to_hash
=> {:items=>[{:value=>100}, {:value=>200}, {:value=>300}]}
```

There's (at least) two ways to do this. You can either define the `multiplicator` node on your child class:

```ruby
class MyDocument
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
```

Or, alternatively, you can use `#parent_node`:

```ruby
class MyDocument
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
```

Both are perfectly acceptable. The latter is slightly more efficient because the `multiplicator` node
will only be parsed once instead of once per `item`. You may have noticed that we used a new option:
`:private`. I'll explain it in the next section.

## More options

### `:private`

The `:private` option removes your node from the ones being evaluated in `#to_hash`. This is
helpful if you want to parse something that is not meant to end up in the parsed schema. Let's revisit the example
from above.

```xml
<document>
  <items multiplicator='100'>
    <item value='1'/>
    <item value='2'/>
    <item value='3'/>
  </items>
</document>
```

Now let's try and remove the `multiplicator` from your parsed hash. Like so:

```ruby
class MyDocument
  include AwesomeXML

  set_context 'document/items'
  node :multiplicator, :integer, attribute: true, private: true
  node :item_values, :integer, array: :true, xpath: './item/@value'

  def item_values
    @item_values.map { |value| value * multiplicator }
  end
end
```

```ruby
my_document.to_hash
=> {:item_values=>[100, 200, 300]}
```

Awesome.

### `:default` and `:default_empty`

Using these options, you can control what happens in case the tag or attribute you wanted to parse is empty
or doesn't even exist. For the former, use `:default_empty`, for the latter, use `:default`.

## More node types

Let's talk about duration nodes. As you may remember, `:duration` is of the native types for `.node`.
They return `ActiveSupport::Duration` objects, which interact freely with each other and with `Time` and
`DateTime` objects.
The special thing about them is that they take a *mandatory* `:format` option. There, you can specify the
format in which the duration you want to parse is available. The format is given in the form of a duration
format string with an easy syntax. Basically, you emulate the format of the given duration string and
replace the numbers with instructions how to treat them. The syntax is `"{#{unit}#{parse_length}}"`.
The `unit` can be one of `D`, `H`, `M`, or `S` (or their lowercase variants), representing days, hours, minutes, and seconds.
The `parse_length` tells the parser how many digits to look for, and can be any integer.

For example, let's say you want to parse a duration string that looks like `'1234'`, where the first two
digits stand for minutes and the last two for seconds. To parse this correctly, use the format string
`'{M2}{S2}'`. Easy enough.

What, though, if the number of digits vary? Maybe your duration string sometimes looks like `'12m34'`,
but when the numbers are single digit, it looks like `'2m1'`. In this case, just don't specify a
`parse_length`. Everything up to the following character (or the end of the duration string) will be
treated as going into the parsed value. The format string that would parse you the correct duration
would be `'{M}m{S}'`.
