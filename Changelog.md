### Development

[full diff](http://github.com/plexus/hexp/compare/v0.4.6...master)

### v0.4.6

* Bugfix: make sure the Node constructors correctly calls the
  constructor defined by Concord. This bug was being triggered by
  asset_packer. Not sure how or why, but this fixes it.

### v0.4.5

* Bugfix: don't do entity escaping inside :script tags, also not when
  there's more than one text node as a child element

### v0.4.4

* Drop the dependency on SASS, use Nokogiri instead for parsing CSS
  selectors

### v0.4.3

Performance improvements

* Introduce MutableTreeWalk to speed up css selection
* Drop Adamantium. This means we have less of a guarantee of deep
  immutability, but it does speed things up
* Prevent type coercion from happening if inputs are already valid
* Raise an exception when a node's tag is not a Symbol

### v0.4.2

* Added Hexp::List#append
* set_attr now simply replaces the full attribute hash, use
  merge_attr for "smart" behavior. % is now an alias of merge_attr,
  not set_attr
* Make the unparser aware of HTML "void" tags (tags that should not
  have a closing tag)

### v0.4.1

* Make Hexp::List#+ return a Hexp::List
* Add Hexp::Node#append as a convenient API for adding child nodes
* Make Unparser Adamantium-immutable so instances can be included in
  Adamantiumized objects
* Skip escaping inside `<script>` tags
* Add a "rails integration" (ugh) to play nice with
  ActiveSupport::SafeBuffer. use `gem 'hexp', require: 'hexp-rails'`
  in your Gemfile

### v0.4.0.beta1

[full diff](http://github.com/plexus/hexp/compare/v0.3.3...v0.4.0.beta1)

* Do our own HTML unparsing, instead of going through Nokogiri,
  causing a big speed improvement.
* Make H[] notation more lenient
  * Make array around list of children optional
    `H[:p, [H[:span, 'foo'], ' ', H[:span, 'bar']]]` =>
    `H[:p, H[:span, 'foo'], ' ', H[:span, 'bar']]`
  * Allow creating node lists without a wrapping node, e.g.
    `H[H[:span, 'foo'], ' ', H[:span, 'bar']]`
* Make Hexp::List and Hexp::TextNode respond to to_html
* Add Hexp::Node#tag? as a complement to Hexp::Node#text?

### v0.3.3

[full diff](http://github.com/plexus/hexp/compare/v0.3.0...v0.3.3)

* Bugfix regarding string values in attribute CSS selectors
* Update dependencies

### v0.3.0

[full diff](http://github.com/plexus/hexp/compare/v0.2.0...v0.3.0)

* Improved CSS selector support
* Handle CDATA sections when parsing through Nokogiri
* Improved documentation

### v0.2.0

* introduce Hexp.build for creating Hexp::Node objects using Builder syntax
* introduce CSS selectors to selectively iterate over parts of a tree
* introduce Hexp.parse to integrate with legacy tools
* expand the API for manipulating nodes
