require 'spec_helper'

describe Hexp::Node::Attributes do
  describe 'attr?' do
    it 'should return true if the attribute is present' do
      expect(H[:a, href: '/foo'].has_attr?(:href)).to be true
    end

    it 'should return true if the attribute is present and empty' do
      expect(H[:a, href: ''].has_attr?(:href)).to be true
    end

    it 'should return false if the attribute is not present' do
      expect(H[:a].has_attr?(:href)).to be false
    end

    it 'should work with a string argument' do
      expect(H[:a, href: '/foo'].has_attr?('href')).to be true
    end
  end

  describe 'class_list' do
    context 'for a node without a class attribute' do
      subject(:node) { H[:div] }

      it 'should return an empty string' do
        expect(node.class_list).to eq []
      end
    end

    context 'for a node with an empty class attribute' do
      subject(:node) { H[:div, class: ''] }

      it 'should return an empty string' do
        expect(node.class_list).to eq []
      end
    end

    context 'for a node with a single class' do
      subject(:node) { H[:div, class: 'daklazz'] }

      it 'should return a list with the single class' do
        expect(node.class_list).to eq ['daklazz']
      end
    end

    context 'for a node with multiple classes' do
      subject(:node) { H[:div, class: 'daklazz otherklazz foo'] }

      it 'should return a list with the single class' do
        expect(node.class_list).to eq ['daklazz', 'otherklazz', 'foo']
      end
    end
  end

  describe 'remove_class' do
    context 'for a node without a class list' do
      it 'should be idempotent' do
        expect(H[:div].remove_class('foo')).to eq H[:div]
      end
    end

    context 'for a node with an empty class list' do
      it 'should remove the attribute' do
        expect(H[:div, class: ''].remove_class('foo')).to eq H[:div]
      end
    end

    context 'for a node with one class' do
      it 'should remove the class attribute when the class is removed' do
        expect(H[:div, class: 'foo'].remove_class('foo')).to eq H[:div]
      end

      it 'should return the node itself when an other class is removed' do
        expect(H[:div, class: 'foo'].remove_class('bar')).to eq H[:div, class: 'foo']
      end
    end

    context 'with a class appearing multiple times in a class list' do
      it 'should remove all instances of the class' do
        expect(H[:div, class: 'foo foo'].remove_class('foo')).to eq H[:div]
      end
    end
  end

  describe 'set_attrs' do
    it 'should set attributes' do
      expect(H[:foo].set_attrs(class: 'bar')).to eq H[:foo, class: 'bar']
    end

    it 'should override attributes' do
      expect(H[:foo, class: 'baz'].set_attrs(class: 'bar')).to eq H[:foo, class: 'bar']
    end
  end

  describe 'merge_attrs' do
    describe 'when passing in a Hash' do
      it 'should set attributes' do
        expect(H[:foo].merge_attrs(class: 'bar')).to eq H[:foo, class: 'bar']
      end

      it 'should merge class lists' do
        expect(H[:foo, class: 'baz'].merge_attrs(class: 'bar')).to eq H[:foo, class: 'baz bar']
      end

      it 'should override attributes that are not class' do
        expect(H[:foo, src: 'baz'].set_attrs(src: 'bar')).to eq H[:foo, src: 'bar']
      end

      it 'should merge keep both old and new attributes' do
        expect(H[:foo, class: 'baz'].merge_attrs(src: 'bar')).to eq H[:foo, class: 'baz', src: 'bar']
      end
    end

    describe 'when passing in a Hexp::Node' do
      it 'should take the nodes attributes to merge with' do
        expect(H[:foo, class: 'klz1'].merge_attrs(H[:bla, class: 'klz2'])).to eq H[:foo, class: 'klz1 klz2']
      end
    end
  end
end
