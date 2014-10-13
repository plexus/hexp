require 'spec_helper'

describe Hexp::Node, 'rewrite' do
  subject(:rewriter) { Hexp::Node::Rewriter.new(hexp, block) }

  let :hexp do
    H[:div, [
        [:a],
        [:p],
        [:br]]]
  end

  context 'without a block' do
    subject { hexp.rewrite(&block) }
    let(:block) { nil }

    it 'returns a Rewriter' do
      expect(subject).to be_instance_of(Hexp::Node::Rewriter)
    end
  end

  context 'with a block that returns [child]' do
    let(:block) { proc {|child, parent| [child] } }

    it 'should return an identical hexpable' do
      expect(subject.to_hexp).to eq(hexp)
    end
  end

  context 'with multiple nestings' do
    let :hexp do
      H[:span, [super()]]
    end

    let :block do
      proc do |child, parent|
        @tags << [child.tag, parent.tag]
        nil
      end
    end

    it 'should traverse depth-first' do
      @tags = []
      rewriter.to_hexp
      expect(@tags).to eq([[:a, :div], [:p, :div], [:br, :div], [:div, :span]])
    end
  end

  context 'when adding nodes' do
    let :block do
      proc do |child, parent|
        raise 'got my own node back' if child.tag == :blockquote
        # wrap paragraphs in a <blockquote>
        if child.tag == :p
          [:blockquote, [child]]
        else
          [child]
        end
      end
    end

    it 'should not pass those nodes again to the block' do
      expect(rewriter.to_hexp).to eql H[:div, [
          [:a],
          [:blockquote, [
              [:p]]],
          [:br]]]
    end
  end

  context 'with a one parameter block' do
    let :hexp do
      H[:parent, [[:child]]]
    end

    let :block do
      proc do |child|
        expect(child).to eq(H[:child])
        [child]
      end
    end

    it 'should receive the child node as its argument' do
      rewriter.to_hexp
    end
  end

  describe 'block response types' do
    context 'when responding with a single node' do
      let :block do
        proc do |child|
          H[:br]
        end
      end

      it 'should replace the existing node' do
        expect(rewriter.to_hexp).to eq H[:div, [ [:br] ]*3 ]
      end
    end

    context 'when responding with an array that starts with a Symbol' do
      let :block do
        proc do |child|
          [:br, {class: 'foo'} ]
        end
      end

      it 'should treat it as a node and replace the existing one' do
        expect(rewriter.to_hexp).to eq H[:div, [ [:br, {'class' => 'foo'}] ]*3 ]
      end
    end

    context 'when responding with a String' do
      let :hexp do
        H[:div, [
            [:p]
          ]
        ]
      end

      let :block do
        proc do |child|
          "Hello"
        end
      end

      it 'should convert it to a text node' do
        expect(rewriter.to_hexp).to eq H[:div, [ Hexp::TextNode.new("Hello") ] ]
      end
    end


    context 'when responding with nil' do
      let :block do
        proc do |node|
          node if [:p, :br].include? node.tag
        end
      end

      it 'should remove the original node' do
        expect(rewriter.to_hexp).to eq H[:div, [ H[:p], H[:br] ]]
      end
    end
  end

  context 'when responding with something else than a Hexp, Array or String' do
    let :block do
      proc do |node|
        Object.new
      end
    end

    it 'should raise a FormatError' do
      expect{rewriter.to_hexp}.to raise_exception(Hexp::FormatError)
    end
  end

  context 'with a css selector argument' do
    let(:selector) { 'p.foo' }

    it 'should delegate to CssSelection, rather than Rewriter' do
      expect(Hexp::Node::CssSelection).to receive(:new).with(hexp, selector).and_return(double(:rewrite => hexp))
      hexp.rewrite(selector)
    end
  end

end
