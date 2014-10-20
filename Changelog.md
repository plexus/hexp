### Development

[full diff](http://github.com/plexus/hexp/compare/v0.3.3...master)

* Make Hexp::List#+ return a Hexp::List

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
