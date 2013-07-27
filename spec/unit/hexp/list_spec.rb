require 'spec_helper'

describe Hexp::List do
  it 'should be equal to an Array with the same contents' do
    expect(Hexp::List[ H[:div] ]).to eq [ H[:div] ]
  end

  describe 'value and type equality' do
    it 'should not be #eql? to an Array with the same contents' do
      expect(Hexp::List[ H[:div] ]).to_not eql [ H[:div] ]
    end
  end

  describe 'inspect' do
    it 'should look exactly like an Array' do
      expect(Hexp::List[ H[:div] ].inspect).to eq '[H[:div]]'
    end
  end
end
