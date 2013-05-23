# HTML Expressions (hexp) Specification

HTML Expressions, hexps for short, are a subset of s-expressions. They provide a convention for working with HTML data in applications in a structured fashion.

Most languages contain a DOM implementation to work with HTML/XML documents, fragments and nodes. However, generating HTML through the DOM API is verbose and tedious. A hexp implementation SHOULD implement conversions from and to DOM documents. A hexp implementation SHOULD NOT convert directly from or to HTML.

A hexp implementation MUST implement hexp normalization. Several shorthands are provided for the convenience of the programmer when entering literal hexps. These non-strict hexps should be normalized to strict hexps before further manipulation.

## Strict hexps

A strict hexp is a triplet, it represents a single HTML node. The first element is the tag name, the second a dictionary of attributes, the third is a list of child nodes.

If the language implements the concept of a symbol (interned string), the tag name MUST BE a symbol. Otherwise it will be represented as a regular string.

The attributes are represented in a dictionary (hash), with both keys and values being strings.

The list of child nodes is a list (array) of other hexps or strings, the latter representing text nodes in the corresponding DOM.

An example in Ruby of a strict hexp :

````ruby
[:div, {'class': 'hexp-example'}, [
    [:p, {}, "Hello, world"]
  ]
]
````

A normalized hexp MUST be made immutable (frozen, persistent) if the runtime supports it. Operations that alter a hexp MUST return a new hexp values, rather than changing the hexp value in-place.

## Non-strict hexps

Following simplifications are allowed for entering literal hexps, the implementation MUST provide a mechanism for converting these to strict hexps.

````ruby
# non-strict -> strict
[:p]                            -> [:p, {}, []]
[:p, {'class' => 'foo'}]        -> [:p, {'class' => 'foo'}, []]
[:p, ['hello,', [:br], 'world'] -> [:p, {}, ['hello,', [:br, {}, []], 'world']
````

### Omitting attributes or children

If the dictionary of attributes is empty, it may be omitted.

If the list of children is empty, it may be omitted.

### A single text node as child

If the represented node its only child is a text node, a single string may be given rather than a list of children. An example would be `<p>Hello, world</p>`, this can be represented as `[:p, "Hello, world"]`, which would be normalized to `[:p, {}, ["Hello, world"]]`.

### Standard coercion protocol

In a dynamically typed object-oriented language, a convention may be set for a protocol that objects can implement to return a strict hexp representation of themselves. For Ruby this will be the `to_hexp` method. In the list of children, objects can be added that implement `to_hexp`. The normalization procedure must detect that the object implements this method, and add the resulting hexps to the list of children.