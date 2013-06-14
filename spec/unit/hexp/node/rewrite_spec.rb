require 'spec_helper'

describe Hexp::Node, 'rewrite' do
  subject { hexp.rewrite(&blk) }
  let :hexp do
    H[:div, [
        [:a],
        [:p],
        [:br]
      ]
    ]
  end

  context 'without a block' do
    let(:blk) { nil }

    it 'returns an Enumerator' do
      expect(subject).to be_instance_of(Enumerator)
    end
  end

  context 'with a block that returns [child]' do
    let(:blk) { proc {|child, parent| [child] } }

    it 'should return an identical hexp' do
      expect(subject).to eq(hexp)
    end
  end

  context 'with multiple nestings' do
    let :hexp do
      H[:span, [super()]]
    end

    let :blk do
      proc do |child, parent|
        @tags << [child.tag, parent.tag]
      end
    end

    it 'should traverse depth-first' do
      @tags = []
      subject
      expect(@tags).to eq([[:a, :div], [:p, :div], [:br, :div], [:div, :span]])
    end
  end

  context 'when adding nodes' do
    let :blk do
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
      subject.should == H[:div, [
          [:a],
          [:blockquote, [
              [:p]
            ]
          ],
          [:br]
        ]
      ]
    end
  end

  context 'with a one parameter block' do
    let :hexp do
      H[:parent, [[:child]]]
    end

    let :blk do
      proc do |child|
        expect(child).to eq(H[:child])
        [child]
      end
    end

    it 'should receive the child node as its argument' do
      subject
    end
  end

  describe 'block response types' do
    context 'when responding with a single node' do
      let :blk do
        proc do |child|
          H[:br]
        end
      end

      it 'should replace the existing node' do
        expect(subject).to eq H[:div, [ [:br] ]*3 ]
      end
    end

    context 'when responding with an array that starts with a Symbol' do
      let :blk do
        proc do |child|
          [:br, {class: 'foo'} ]
        end
      end

      it 'should treat it as a node and replace the existing one' do
        expect(subject).to eq H[:div, [ [:br, {'class' => 'foo'}] ]*3 ]
      end
    end

    context 'when responding with nil' do
      let :blk do
        proc do |node|
          [] if node.tag == :a
        end
      end

      it 'should keep the original node' do
        expect(subject).to eq H[:div, [ H[:p], H[:br] ]]
      end
    end

  end

end
