require 'spec_helper'

describe Hexp::Node::CssSelection do
  subject(:selection) { described_class.new(hexp, selector) }

  context 'given a single tag' do
    let(:selector) { 'span' }

    context 'with a depth of 1' do
      let(:hexp) { H[:span] }

      it 'should match all nodes of that tag' do
        expect(selection.to_a).to eq [ H[:span] ]
      end
    end

    context 'with a depth of 2' do
      let(:hexp) { H[:span, {id: 'span-1'}, H[:span, id: 'span-2']] }

      it 'should match all nodes of that tag' do
        expect(selection.to_a).to eq [ H[:span, id: 'span-2'], hexp ]
      end
    end
  end

  context 'given a tag and class' do
    let(:selector) { 'span.foo' }

    context 'with a depth of 1' do
      context 'with a matching tag and class' do
        let(:hexp) { H[:span, class: 'foo bar'] }
        its(:to_a) { should eq [ hexp ] }
      end

      context 'with only a matching tag' do
        let(:hexp) { H[:span] }
        its(:to_a) { should eq [] }
      end

      context 'with only a matching class' do
        let(:hexp) { H[:div, class: 'foo'] }
        its(:to_a) { should eq [] }
      end
    end
  end

  context 'given a sequence of tags' do
    let(:selector) { 'ul li' }

    context 'with a minimal matching tag' do
      let(:hexp) { H[:ul, H[:li]] }
      its(:to_a) { should eq [ H[:li] ] }
    end

    context 'with other tags in between' do
      let(:hexp) do
        H[:body, [
            H[:ul, [
                H[:span, [
                    H[:li, id: 'foo'],
                    H[:li, id: 'bar']]],
                H[:li, id: 'baz']]]]]
      end
      its(:to_a) { should eq %w[foo bar baz].map{|id| H[:li, id: id] } }
    end
  end

  describe 'rewrite' do
    let(:hexp) do
      H[:ul, [
          H[:li, [
              H[:a, href: '/foo']]],
          H[:a, href: '/moo']]]
    end
    let(:selector) { 'li a' }

    it 'should only affect nodes that match the selection' do
      expect(selection.rewrite {|node| node.add_class('selected')}).to eq(
        H[:ul, [
            H[:li, [
                H[:a, href: '/foo', class: 'selected']]],
            H[:a, href: '/moo']]]
      )
    end
  end
end
