require 'spec_helper'

describe Hexp, 'parse' do
  context 'with an empty document' do
    let(:html) { '' }

    it 'should raise an exception' do
      expect{ Hexp.parse(html) }.to raise_exception Hexp::ParseError
    end
  end

  it 'should parse a single tag' do
    expect(Hexp.parse('<a>Hello!</a>')).to eq H[:a, 'Hello!']
  end

  it 'should parse nested tags' do
    expect(Hexp.parse('<a>Ciao <em>Bella</em></a>')).to eq H[:a, ['Ciao ', H[:em, 'Bella']]]
  end

  it 'should parse attributes' do
    expect(Hexp.parse('<a href="pretty">Ciao Bella</a>')).to eq H[:a, {href: 'pretty'}, 'Ciao Bella']
  end

  it 'should parse style tags' do
    expect(Hexp.parse('<html><head><style type="text/css">h1 {font-weigth: 400;}</style></head></html>')).to eq(
      H[:html,
        H[:head,
          H[:style, {type: 'text/css'}, 'h1 {font-weigth: 400;}']
        ]
      ]
    )
  end
end
