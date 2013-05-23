require 'spec_helper'

H=Hexp::Triplet

describe Hexp::Triplet do
  describe 'normalization' do
    describe 'with a single parameter' do
      it 'should return a triplet' do
        H[:div].count.should == 3
      end
      it 'should treat the first as the tag' do
        H[:div][0].should == :div
      end
      it 'should set an empty attribute list' do
        H[:div][1].should == {}
      end
      it 'should set an empty children list' do
        H[:div][2].should == []
      end
    end

    describe 'with two parameters' do
      it 'should treat the first as the tag' do
        H[:div, {class: 'foo'}][0].should == :div
      end
      it 'should treat the second as the attribute list, if it is a Hash' do
        H[:div, {class: 'foo'}][1].should == {class: 'foo'}
      end
      it 'should treat the second as a list of children, if it is an Array' do
        H[:div, []][2].should == []
      end
    end

    describe 'with a single text child node' do
      it 'should set is as the single child' do
        H[:div, "this is text in the div"][2].should == ["this is text in the div"]
      end
    end

    describe 'with child nodes' do
      it 'must normalize them recursively' do
        H[:div, [
            [:h1, "Big Title"],
            [:p, {class: 'greeting'}, "hello world"],
            "Some loose text"
          ]
        ][2].should == [
            [:h1, {},                  ["Big Title"]   ],
            [:p,  {class: 'greeting'}, ["hello world"] ],
            "Some loose text"
          ]
      end
    end

    describe 'with bad input' do
      it 'should raise exception' do
        expect { H[:p, {}, [123]] }.to raise_exception
      end
    end
  end
end
