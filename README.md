# AwesomeXML

AwesomeXML is a library that lets your Ruby classes parse arbitrary data from XML documents into a hash.
The hash can be structured completely freely. The parsing itself is based on [Nokogiri](https://github.com/sparklemotion/nokogiri). The concept was
inspired by [xml-mapping](https://github.com/multi-io/xml-mapping).

## Include it

Include `AwesomeXML::Root` in any class you want to hold the root node of your XML document.
Make sure that the document itself is stored in an attribute `data`. Like this:

```ruby
class MyRoot
  include AwesomeXML::Root

  attr_reader :data

  def intitalize(data)
    @data = data
  end
end
```

## Create your first awesome node

Let's say you have this XML document and you want to parse the contents of the `<title></title>` node.

```xml
<document>
  <title>This is a document.</title>
</document>
```

`AwesomeXML::Root` defines class methods on your class that correspond to types of nodes. One of the simplest is the `.simple_node`.
It takes in
  - a symbol, which will be the name of your node.
  - the type which the parser will assume the parsed value has (currently supported are `:text`, `:integer`, `:float`, and `:duration`).
  - an `XPath` to the node you want to evaluate. If you pass in an `XPath` that returns a `NodeSet` instead of a
    single node, only the first one is evaluated.

This is how you do it:

```ruby
class MyDocument < Struct.new(:data) # don't do this in real life, but it'll keep this tutorial shorter
  include AwesomeXML::Root

  simple_node :text, :title, '//title'
end
```

This then gives you access to the following method:

```ruby
my_document = MyDocument.new("<document><title>This is a document.</title></document>")
=> #<struct MyDocument data="<document><title>This is a document.</title></document>">

my_document.title
=> "This is a document."
```

Instead of using `.simple_node(type, name, xpath)`, you can also use the predefined `.text_node(name, xpath)`,
`.integer_node(name, xpath)`, and so on.

## Method nodes

If you want, you can define your node in a method. Like this:

```ruby
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  simple_node :text, :title, '//title'
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

Including `AwesomeXML::Root` will define the method `#to_hash` on your class. It traverses all the nodes
you defined in your class (including the ones declared with `.method_node`) and returns values in a hash
that follows the structure you defined. Let's take the example from the section above. Then, `#to_hash`
would do the following:

```ruby
my_document = MyDocument.new("<document><title>This is a document.</title></document>")
=> #<struct MyDocument data="<document><title>This is a document.</title></document>">

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
you can do that with `.child_node(name, child_node_class_name, new_current_node)`:

```ruby
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  simple_node :text, :title, '//title'
  child_node :item, 'Item', 'document/item'

  class Item
    include AwesomeXML::Child

    integer_node :reference, '@ref'
    text_node :owner, '/owner'
  end
end
```

Let me explain what's going on here.

First, you declare that your root has a child node, whose nodes you'll define in turn in the class
`MyDocument::Item`. You have to pass in the class' name and not the class. The namespace `MyDocument::`
for the new class is added automatically.

The third argument to the `.child_node` method is an `XPath` to the node that gets passed into the
initializer of the `MyDocument::Item` class. That will be the new current node in which context the `XPath`s of
its own nodes will be evaluated. That way you can write just `'@ref'` instead of `'document/item/@ref'`.
If you don't want to change the current node for the subclass, just pass in `'.'`.

Then, you need to include the `AwesomeXML::Child` module in your child node class. This gives you all the magic
you get from `AwesomeXML::Root`, but also some extra stuff. E.g., you don't have to define `#initialize` anymore.
`.child_node` also passes in the instance of its class in which its defined method was called, and you can access it
in the child class with `#parent_node`.
You'll see more about that later.

## Array Nodes

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
{ title: "This is a document.", item_references: [123, 456, 789] }
```

Fret no more, just use `.simple_array_node(type, name, xpath)`:

```ruby
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  simple_array_node :integer, :item_references, 'document/item/@ref'
end
```

Pretty self-explanatory, right? Needless to say, you can also use `text_array_node`, `integer_array_node`,
etc., if you think that looks tidier (I do).

Okay, you say, that's a very simple array, indeed. What if I want an array of hashes? Like so:
```ruby
{ title: "This is a document.", items: [{ reference: 123 }, { reference: 456 }, { reference: 789 }] }
```

Well, I've got a method for you: `.child_array_node(name, child_node_class_name, new_current_node)`. It works
just like `.child_node`:

```ruby
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  child_array_node :item, 'Item', 'document/item'

  class Item
    include AwesomeXML::Child

    integer_node :reference, '@ref'
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
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  integer_array_node(:items, 'document/item/@index') { |values| values.map { |value| value - 1 } }
end

my_document.to_hash
=> {:items=>[0, 1, 2]}

```

That's better. Note that `*_array_nodes` yield the whole array to the block and not an `Enumerator`.

There's another twist to this block passing, though. AwesomeXML also yields the instance of your class
to the block so you can actually access other nodes inside the block! Let's see it in action.

Your XML data:
```xml
<document>
  <items multiply-with='100'>
    <item value='1'/>
    <item value='2'/>
    <item value='3'/>
  </items>
</document>
```

Your AwesomeXML class:

```ruby
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  integer_node :multiply_with, 'document/items/@multiply-with'
  integer_array_node(:item_values, 'document/items/item/@value') do |values, instance|
    values.map { |value| value * instance.multiply_with }
  end
end

my_document.to_hash
=> {:multiply_with=>100, :item_values=>[100, 200, 300]}
```


## `:private` option

To all `*_node` methods (except `.method_node`, since it doesn't really make sense there), you can always pass
in an options hash as the last argument. Currently, there's only one option being supported, called `private`.
The default is `false`. What it does is remove your node from the ones being evaluated in `#to_hash`. This is
helpful if you want to parse something that is not meant to end up in the parsed schema. Let's take the example
from above and remove the `multiply_with` from your parsed hash. Like so:

```ruby
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  integer_node :multiply_with, 'document/items/@multiply-with', private: true
  integer_array_node(:item_values, 'document/items/item/@value') do |values, instance|
    values.map { |value| value * instance.multiply_with }
  end
end

my_document.to_hash
=> {:item_values=>[100, 200, 300]}
```

Awesome.

## `#parent_node`

This method is available on all class instances including the `AwesomeXML::Child` modules. It returns the
instance of the class instance it was instantiated from. Let's see how that can be useful. Let's again use
the XML document from the above two examples.

```xml
<document>
  <items multiply-with='100'>
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

There's (at least) two ways to do this. You can either define the `multiply_with` node on your child class:

```ruby
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  child_array_node :items, 'Item', 'document/items/item'

  class Item
    include AwesomeXML::Child

    integer_node :multiply_with, '../@multiply-with', private: true
    integer_node(:value, '@value') { |value, instance| value * instance.multiply_with }
  end
end
```

Or, alternatively, you can use `#parent_node`:

```ruby
class MyDocument < Struct.new(:data)
  include AwesomeXML::Root

  integer_node :multiply_with, 'document/items/@multiply-with', private: true
  child_array_node :items, 'Item', 'document/items/item'

  class Item
    include AwesomeXML::Child

    integer_node(:value, '@value') { |value, instance| value * instance.parent_node.multiply_with }
  end
end
```

Both are perfectly acceptable. They even have the same amount of lines.

## More node types

Let's talk about duration nodes. As you may remember, `:duration` is an accepted type for `.simple_node`.
They return `ActiveSupport::Duration` objects, which interact freely with each other and with `Time` and
`DateTime` objects.
The special thing about them is that they take a *mandatory* `:format` option. There, you can specify the
format in which the duration you want to parse is available. The format is given in the form of a duration
format string with an easy syntax. Basically, you emulate the format of the given duration string and
replace the numbers with instructions how to treat them. The syntax is `"{#{unit}#{parse_length}}"`.
The `unit` can be one of `D`, `H`, `M`, or `S`, representing days, hours, minutes, and seconds.
The `parse_length` tells the parser how many digits to look for, and can be any integer.

For example, let's say you want to parse a duration string that looks like `'1234'`, where the first two
digits stand for minutes and the last two for seconds. To parse this correctly, use the format string
`'{M2}{S2}'`. Easy enough.

What, though, if the number of digits vary? Maybe your duration string sometimes looks like `'12m34'`,
but when the numbers are single digit, it looks like `'2m1'`. In this case, just don't specify a
`parse_length`. Everything up to the following character (or the end of the duration string) will be
treated as going into the parsed value. The format string that would parse you the correct duration
would be `'{M}m{S}'`.

## Summary of node types

- `.constant_node(name, value, options = {})` - defines a method that returns a constant value you specify.
- `.method_node(name, options = {})` - adds the specified name to the node registry.
- `.simple_node(type, name, xpath, options = {}, &block)` - defines a method that evaluates the `XPath` specified node
  and casts it as the specified type. Possible types are `:text`, `:integer`, `:float`, `:duration`. Also available as
  `.text_node`, `.integer_node`, `.float_node`, `.duration_node`.
- `.child_node(name, node_class_name, new_current_node, options = {}, &block)` - defines a method that initializes an
  instance of the specified `AwesomeXML::Child` class. `XPath`s in that class are evaluated in the context
  of the new current node.
- `.simple_array_node` and `.child_array_node` - work like their non-`array` counterparts, except they evaluate
  each node passed in through the `xpath` argument and return it as an array.
