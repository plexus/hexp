require 'spec_helper'

describe Hexp::Node::Selector do
  subject(:selector) { Hexp::Node::Selector.new(hexp, block) }
  let(:yielded_elements) { [] }
  let(:block) { proc {|el| yielded_elements << el } }
  let(:hexp) { H[:div, [[:span]]] }

  describe 'as Enumerable' do
    let(:block) { proc {|el| el.tag == :span} }

    it 'should enumerate elements for which the block returns trueish' do
      expect(selector.to_a).to eq [H[:span]]
    end
  end

  describe 'rewriting operations' do
    let(:block) { proc {|el| el.tag == :span} }

    it 'should perform them on elements that match' do
      expect(selector.attr('class', 'matched').to_hexp).to eq(
        H[:div, [[:span, {class: 'matched'}]]]
      )
    end

    describe 'wrap' do
      let(:hexp) { H[:ul, [[:a, href: 'foo'], [:a, href: 'bar']]] }
      let(:block) { proc {|el| el.tag == :a} }
      it 'should be able to wrap element' do
        expect(selector.wrap(:li).to_hexp).to eq(
           H[:ul, [[:li, H[:a, href: 'foo']], [:li, H[:a, href: 'bar']]]]
        )
      end
    end
  end

  context 'with a single element' do
    let(:hexp) { H[:div] }

    it 'should be lazy' do
      block.should_not_receive(:call)
      selector
    end

    it 'should yield the root element when realized' do
      block.should_receive(:call).once.with(H[:div])
      selector.each {}
    end
  end

  context 'with nested elements' do
    let(:hexp) {
      H[:div, [
          [:span, "hello"],
          [:span, "world"]]]}

    it 'should traverse the whole tree once, depth-first' do
      selector.each {}
      expect(yielded_elements).to eq [
        Hexp::TextNode.new("hello"),
        H[:span, "hello"],
        Hexp::TextNode.new("world"),
        H[:span, "world"],
        hexp
      ]
    end
  end
end
