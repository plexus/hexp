$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'hexp'
require 'minitest/autorun'

module Hexp
  def self.from_nokogiri(node)
    attrs = node.attributes.map do |k,v|
      [k.to_sym, v.value]
    end
    children = node.children.map do |child|
      case child
      when ::Nokogiri::XML::Text
        Hexp::TextNode.new(child.text)
      when ::Nokogiri::XML::Node
        from_nokogiri(child)
      end
    end
    H[node.name.to_sym, Hash[attrs], children]
  end
end

class Nokogiri::XML::Node
  def to_hexp
    Hexp.from_nokogiri(self)
  end
end

class Nokogiri::XML::Document
end

describe Hexp, 'from_nokigiri' do
  def doc
    @doc ||= Nokogiri::HTML::Document.new
  end

  it 'should convert a single node' do
    h3 = Nokogiri::XML::Node.new "h3", doc
    Hexp.from_nokogiri(h3).must_equal H[:h3]
  end

  it 'should extract arguments, if there are any' do
    h3 = Nokogiri::XML::Node.new "h3", doc
    h3[:class] = 'foo'
    Hexp.from_nokogiri(h3).must_equal H[:h3, {class: 'foo'}]
  end

  it 'should convert children' do
    div  = Nokogiri::XML::Node.new "div", doc
    p    = Nokogiri::XML::Node.new "p", doc
    span = Nokogiri::XML::Node.new "span", doc
    div << p
    div << span

    Hexp.from_nokogiri(div).must_equal H[:div, [[:p], [:span]]]
  end

  it 'should convert text nodes' do
    div  = Nokogiri::XML::Node.new "div", doc
    p    = Nokogiri::XML::Node.new "p", doc
    text = Nokogiri::XML::Text.new "text", doc
    div << p
    div << text

    Hexp.from_nokogiri(div).must_equal H[:div, [[:p], "text"]]
  end
end

# >> Run options: --seed 54619
# >>
# >> # Running tests:
# >>
# >> ....
# >>
# >> Finished tests in 0.003244s, 1233.0547 tests/s, 1233.0547 assertions/s.
# >>
# >> 4 tests, 4 assertions, 0 failures, 0 errors, 0 skips
