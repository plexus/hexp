require 'spec_helper'

describe Hexp::Node::Normalize, '#call' do
  subject(:normalized) { Hexp::Node[*node] }

  describe 'with a single element' do
    let(:node) { [:div] }

    it 'should treat the first as the tag' do
      expect(normalized.tag).to eq :div
    end
    it 'should set an empty attribute list' do
      expect(normalized.attributes).to eq Hash[]
    end
    it 'should set an empty children list' do
      expect(normalized.children).to eql Hexp::List[]
    end
  end

  describe 'with two parameters' do
    let(:node) { [:div, {class: 'foo'}] }

    it 'should treat the first as the tag' do
      subject.tag.should == :div
    end
    it 'should treat the second as the attribute list, if it is a Hash' do
      subject.attributes.should == {'class' => 'foo'}
    end
    it 'should treat the second as a list of children, if it is an Array' do
      subject.children.should == Hexp::List[]
    end
  end

  describe 'with a single text child node' do
    let(:node) { [:div, "this is text in the div"] }

    it 'should set is as the single child' do
      subject.children.should == Hexp::List["this is text in the div"]
    end
  end

  describe 'with child nodes' do
    let(:node) {
      [:div, [
          [:h1, "Big Title"],
          [:p, {class: 'greeting'}, "hello world"],
          "Some loose text"
        ]
      ]
    }

    it 'must normalize them recursively' do
      subject.children.should == Hexp::List[
        Hexp::Node[:h1, {},                  Hexp::List["Big Title"]   ],
        Hexp::Node[:p,  {class: 'greeting'}, Hexp::List["hello world"] ],
        "Some loose text"
      ]
    end
  end

  describe 'with an object that responds to to_hexp' do
    let(:hexpable) {
      Class.new do
        def to_hexp
          Hexp::Node[:em, "I am in your hexpz"]
        end
      end
    }
    let(:node) {
      [:div, [ hexpable.new ] ]
    }

    it 'must expand that object' do
      subject.children.should == Hexp::List[
        Hexp::Node[:em, {}, Hexp::List["I am in your hexpz"] ]
      ]
    end
  end

  context 'with a nil in the child list' do
    let(:node) { [:div, [nil]] }
    it 'should raise an exception' do
      expect{normalized}.to raise_exception(Hexp::FormatError)
    end
  end

end
