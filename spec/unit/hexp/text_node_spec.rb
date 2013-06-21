require 'spec_helper'

describe Hexp::TextNode do
  subject { described_class.new('some string') }

  describe 'Node triplet' do
    its(:tag)        { should be_nil }
    its(:attributes) { should eq({}) }
    its(:attributes) { should be_frozen }
    its(:children)   { should eq([]) }
    its(:children)   { should be_frozen }
  end

  describe 'DSL methods' do
    describe 'attr' do
      it 'should raise error when attributes are set' do
        expect{subject.attr('class', 'foo')}.to raise_error(Hexp::IllegalRequestError)
      end

      it 'should return nil for attr get requests' do
        expect(subject.attr('class')).to be_nil
      end

      it 'should raise an ArgumentError when called with too many arguments' do
        expect{subject.attr('class', 'foo', 'foo')}.to raise_error(ArgumentError)
      end
    end

    its(:text?)   { should be_true }
    its(:rewrite) { should eq(subject) }
    its(:to_hexp) { should eq(subject) }

    describe 'class?' do
      it 'should always return false' do
        expect(subject.class?('strong')).to be_false
      end
    end
  end
end
