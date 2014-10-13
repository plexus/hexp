require 'spec_helper'

describe Hexp::Node, 'class?' do
  context 'with no class attribute set' do
    it 'should return false' do
      expect(H[:p].class?('strong')).to be_falsey
    end
  end

  context 'with a single class set' do
    it 'should return true if the class name is the same' do
      expect(H[:p, class: 'strong'].class?('strong')).to be true
    end

    it 'should return false if the class name is not same' do
      expect(H[:p, class: 'strong'].class?('foo')).to be false
    end

    it 'should return false if the class name is a partial match' do
      expect(H[:p, class: 'strong'].class?('stron')).to be false
    end
  end

  context 'with multiple classes set' do
    it 'should return true if the class name is part of the class list' do
      expect(H[:p, class: 'banner strong'].class?('strong')).to be true
    end

    it 'should return false if the class name is not in the class list' do
      expect(H[:p, class: 'banner strong'].class?('foo')).to be false
    end

    it 'should return false if the class name is a partial match' do
      expect(H[:p, class: 'banner strong'].class?('er str')).to be false
    end
  end
end
