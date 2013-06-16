require 'spec_helper'

describe Hexp::Node, 'attr' do
  subject    { hexp.attr(*args)      }
  let(:hexp) { H[:div, class: 'foo'] }

  context 'with a single string argument' do
    let(:args) { ['class'] }

    it 'should return the attribute value by that name' do
      expect(subject).to eq('foo')
    end
  end

  context 'with a single symbol argument' do
    let(:args) { [:class] }

    it 'should return the attribute value by that name' do
      expect(subject).to eq('foo')
    end
  end

  context 'with two argument' do
    let(:args) { ['data-id', '7'] }

    it 'should return a new Hexp::Node' do
      expect(subject).to be_instance_of(Hexp::Node)
    end

    it 'should set the attribute value' do
      expect(subject.attributes['data-id']).to eq('7')
    end

    it 'should leave other attributes untouched' do
      expect(subject.attributes['class']).to eq('foo')
    end

    context 'with a nil value' do
      let(:args) { ['class', nil] }

      it 'should unset the attribute' do
        expect(subject.attributes).to eq({})
      end
    end
  end

  context 'with too many arguments' do
    let(:args) { ['class', 'baz', 'bar'] }

    it 'should raise an ArgumentError' do
      expect{ subject }.to raise_error(ArgumentError)
    end
  end

end
