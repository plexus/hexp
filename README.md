[![Gem Version](https://badge.fury.io/rb/hexp.png)][gem]
[![Build Status](https://secure.travis-ci.org/plexus/hexp.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/plexus/hexp.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/plexus/hexp.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/plexus/hexp/badge.png?branch=master)][coveralls]

[gem]: https://rubygems.org/gems/hexp
[travis]: https://travis-ci.org/plexus/hexp
[gemnasium]: https://gemnasium.com/plexus/hexp
[codeclimate]: https://codeclimate.com/github/plexus/hexp
[coveralls]: https://coveralls.io/r/plexus/hexp

# Hexp

**Hexp** (pronounced [ˈɦækspi:]) is a DOM API for Ruby. It lets you treat HTML in your applications as objects, instead of strings. It is a standalone, framework independent library. You can use it to build full web pages, or to clean up your helpers and presenters.

## Fundamentals

The three central classes are `Hexp::Node`, `Hexp::TextNode`, and `Hexp::List`. Instances of these classes are immutable. You can mostly treat `TextNode` as a `String` and `List` as an `Array`, except that they're immutable, and come with some extra convenience functions.

Take this bit of HTML

``` html
<nav id="menu">
  <ul>
    <li>Home</li>
    <li>Lolcats</li>
    <li>Games</li>
  </ul>
</nav>
```

If we would spell out all the objects, it would be represented as

``` ruby
include Hexp

Node.new(:nav, {"id"=>"menu"},
  List.new([
    Node.new(:ul, {},
      List.new([
        Node.new(:li, {}, List.new([TextNode.new("Home")])),
        Node.new(:li, {}, List.new([TextNode.new("lolcats")])),
        Node.new(:li, {}, List.new([TextNode.new("Games")]))
      ])
    )
  ])
)
```

The `Hexp::Node` constructor is lenient though. It knows how to wrap things in `TextNode` and `List` instances, and it will let you omit the attributes Hash if it's empty, so you never actually type all of that out.

The above simplifies to:

``` ruby
Node.new(:nav, {"id"=>"menu"},
  Node.new(:ul,
    Node.new(:li, "Home"),
    Node.new(:li, "lolcats"),
    Node.new(:li, "Games")
  )
)
```

There's also a shorthand syntax:

``` ruby
node = H[:nav, {"id"=>"menu"},
         H[:ul,
           H[:li, "Home"],
           H[:li, "Lolcats"],
           H[:li, "Games"]]]

puts node.to_html
```

If the first argument to `H[...]` is a Symbol, than the result is a `Node` otherwise it's a `List`.

You can parse exisiting HTML to Hexp with `Hexp.parse(...)`.

### Hexp::Node

A `Node` has a `#tag`, `#attrs` and `#children`. The methods `#set_tag`, `#set_attrs` and `#set_children` return a new updated instance.

``` ruby
node = H[:p, { class: 'bold' }, "A lovely paragraph"]
node.tag      # => :p
node.attrs    # => {"class"=>"bold"}
node.children # => ["A lovely paragraph"]

node.set_tag(:div)
# => H[:div, {"class"=>"bold"}, ["A lovely paragraph"]]

node.set_attrs({id: 'para-1'})
# => H[:p, {"id"=>"para-1"}, ["A lovely paragraph"]]

node.set_children(H[:em, "Ginsberg said:"], "The starry dynamo in the machinery of night")
# => H[:p, {"class"=>"bold"}, [H[:em, ["Ginsberg said:"]], "The starry dynamo in the machinery of night"]]
```

#### Predicates

``` ruby
node.tag?(:p) # => true
node.text? # => false
node.children.first.text? # => true
```

#### Attributes

``` ruby
# [] : As in Nokogiri/Hpricot, attributes can be accessed with hash syntax
node['class'] # => "bold"

# attr : Analogues to jQuery's `attr`, read-write based on arity
node.attr('class') # => "bold"
node.attr('class', 'bourgeois') # => H[:p, {"class"=>"bourgeois"}, ["A lovely paragraph"]]

node.has_attr?('class') # => true
node.class?('bold') # => true
node.add_class('daring') # => H[:p, {"class"=>"bold daring"}, ["A lovely paragraph"]]
node.class_list # => ["bold"]
node.remove_class('bold') # => H[:p, ["A lovely paragraph"]]
node.remove_attr('class') # => H[:p, ["A lovely paragraph"]]

# merge_attrs : Does a Hash#merge on the attributes, but the class
# attribute is treated special. aliased to %
node.merge_attrs(class: 'daring', id: 'poem')
# => H[:p, {"class"=>"bold daring", "id"=>"poem"}, ["A lovely paragraph"]]
```

#### Children

``` ruby
node.empty? # => false
node.append(H[:blink, "ARRSOME"], H[:p, "bye"]) # => H[:p, {"class"=>"bold"}, ["A lovely paragraph", H[:blink, ["ARRSOME"]], H[:p, ["bye"]]]]
node.text # => "A lovely paragraph"
node.map_children { |ch| ch.text? ? ch.upcase : ch } # => H[:p, {"class"=>"bold"}, ["A LOVELY PARAGRAPH"]]
```

#### CSS Selectors

``` ruby
node.select('p')
# => #<Enumerator: #<Hexp::Node::CssSelection @node=H[:p, {"class"=>"bold"}, ["A lovely paragraph"]] @css_selector="p" matches=true>:each>
node.replace('.warn') {|warning| warning.add_class('bold') }
```

#### The rest

``` ruby
puts node.pp
node.to_html
node.to_dom # => Convert to Nokogiri
```

### Hexp::List

A `Hexp::List` wraps and delegates to a Ruby Array, so it has the same
API as Array. Methods which mutate the Array will raise an exception.

Additionally `Hexp::List` implements `to_html`, `append`, and `+`. Just like built in collections, the class implements `[]` as an alternative constructor.

Equality checks with `==` only compare value equality, so comparing to an Array with the same content returns true. Use `eql?` for a stronger "type and value" equality.

``` ruby
list = Hexp::List[H[:p, "hello, world!"]]
list.append("what", "a", "nice", "day")
#=> [H[:p, ["hello, world!"]], "what", "a", "nice", "day"]
```

## hexp-rails

There is a thin layer of Rails integration included. This makes Hexp aware of the `html_safe` / `html_safe?` convention used to distinguish text from markup. It also aliases `to_html` to `to_s`, so Hexp nodes and lists can be used transparently in templates.

``` erb
<%= H[:p, legacy_helper] %>
```

You need to explicitly opt-in to this behaviour. The easiest is to add a 'require' to your Gemfile

``` ruby
gem 'hexp', require: 'hexp-rails'
```

## Builder

If you like the Builder syntax available in other gems like Builder and Hpricot, you can use `Hexp.build` to achieve the same

``` ruby
Hexp.build do
  div id: 'warning-sign' do
    span "It's happening!"
    ul.warn_list do
      li "Cats are taking over the world"
      li "The price of lasagne has continued to rise"
    end
  end
end

# H[:div, {"id"=>"warning-sign"}, [
#   H[:span, [
#     "It's happening!"]],
#   H[:ul, {"class"=>"warn_list"}],
#   H[:li, [
#     "Cats are taking over the world"]],
#   H[:li, [
#     "The price of lasagne has continued to rise"]]]]
```

## to_hexp

When an object implements `to_hexp` it can be used where you would otherwise use a node. This can be useful for instance to create components that know how to render themselves.

Yaks does not contain any core extensions, but there is an optional, opt-in, implementationof `to_hexp` for NilClass, so nils in a list of nodes won't raise an error. This lets you write things like

``` ruby
H[:p,
  some_node if some_condition?,
  other_node if other_condition?
]
```

You can use it with `require 'hexp/core_ext/nil'`. Loading `hexp-rails` will automatically include this because, let's be honest, if you're using Rails a single monkey patch won't make the difference.

## Related projects

* [Hexp-Kramdown](https://github.com/plexus/hexp-kramdown) Convert Markdown documents of various flavors to Hexp
* [Slippery](https://github.com/plexus/slippery) Generate HTML/JS slides from Markdown. Supports backends for Reveal.js, Deck.js, and Impress.js.
* [Yaks-HTML](https://github.com/plexus/slippery) Uses Hexp to render hypermedia API resources to HTML
* [AssetPacker](https://github.com/plexus/asset_packer) Find all images, stylesheets, and javascript references in a HTML file, save them to local files, and return an updated HTML file pointing to the local resources.
