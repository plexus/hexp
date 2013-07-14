require 'spec_helper'

describe Hexp, 'Array' do
  context 'with an array as input' do
    it 'should return the array' do
      expect(Hexp.Array([:foo])).to eq([:foo])
    end
  end

  context 'with a single object as an input' do
    it 'should wrap it in an array' do
      expect(Hexp.Array(:foo)).to eq([:foo])
    end
  end

  context 'with an object that responds to to_ary' do
    let(:array_like) do
      Class.new { def to_ary; [1,2,3] ; end }.new
    end

    it 'should return the result of to_ary' do
      expect(Hexp.Array(array_like)).to eq([1,2,3])
    end
  end
end

describe Hexp, 'build' do
  it 'should delegate to Hexp::Builder.new' do
    block = proc {}
    expect(Hexp::Builder).to receive(:new).with(:div, class: 'moambe', &block)
    Hexp.build(:div, class: 'moambe', &block)
  end
end
