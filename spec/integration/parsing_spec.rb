require 'spec_helper'

describe 'parsing HTML to hexp' do
  it 'should parse a single tag' do
    expect(Hexp.parse('<a>Hello!</a>')).to eq H[:a, 'Hello!']
  end

  it 'should parse nested tags' do
    expect(Hexp.parse('<a>Ciao <em>Bella</em></a>')).to eq H[:a, ['Ciao ', H[:em, 'Bella']]]
  end

  it 'should parse attributes' do
    expect(Hexp.parse('<a href="pretty">Ciao Bella</a>')).to eq H[:a, {href: 'pretty'}, 'Ciao Bella']
  end

end
