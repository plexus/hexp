http://begriffs.github.io/showpiece/

TODO
====
* Rename Hexp::Node to Hexp::Element
* Rename Selector to Selection

Issues
======

Root elements should not be treated separately

A `rewrite` operation currently yields all nodes except the root node. Rewrite allows you to replace a node with zero, one or more nodes. My thinking at the time was that I wanted to make sure a single Hexp was returned, so if one could rewrite the root node that would be problematic.

This however makes for a special case that is not very intuitive. When implementing `Hexp::Node::Selector` I came across this again. One can use a Selector strictly as an Enumerable

```ruby
# Find the first child element of all elements with class="strong"
hexp.select {|el| el.class? 'strong' }.map {|el| el.children.first }
```

In this case there is no reason why that shouldn't iterate the whole tree, including the node. Other operations on `Selector` however do a Rewrite of the selected elements, and in this case the "all-except-the-root-node" limitation applies.

``` ruby
# Add class="strong" to all divs
H[:div, [
    [:div, 'one'],
    [:div, 'two']
  ]
].select{|node| node.tag==:div}.attr('class', 'strong').to_hexp
#=> H[:div, [H[:div, {"class"=>"strong"}, ["one"]], H[:div, {"class"=>"strong"}, ["two"]]]]
```

The top-level node is unaffected. To remove this limitation `Rewriter` will have to return a `Hexp::List` when zero or multiple elements are returned. Hexp::Node and Hexp::List will also have to implement as much as possible the same interface, so they can be largely used intechangably. This should especially be possible for all select/rewrite operations.
