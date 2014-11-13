RSpec.describe Hexp::MutableTreeWalk do

  let(:node) { H[:ul, H[:p, [H[:li, 'foo', 'boo'], H[:li, 'bar']]]] }
  let(:walk) { Hexp::MutableTreeWalk.new(node) }

  it 'should start at the root' do
    expect(walk.current).to eql node
  end

  it 'should not have a parent at the root' do
    expect(walk.parent).to be_nil
  end

  it 'should descend to the children' do
    walk.next!
    expect(walk.current).to eql  H[:p, [H[:li, ["foo", "boo"]], H[:li, ["bar"]]]]
  end

  it 'should go depth first' do
    2.times { walk.next! }
    expect(walk.current).to eql  H[:li, 'foo', 'boo']
  end

  it 'should also do text nodes' do
    3.times { walk.next! }
    expect(walk.current).to eq 'foo'
  end

  it 'should go left to right' do
    4.times { walk.next! }
    expect(walk.current).to eq 'boo'
  end

  it 'should go back up and right' do
    5.times { walk.next! }
    expect(walk.current).to eql H[:li, 'bar']
  end

  it 'should finish on nil' do
    7.times { walk.next! }
    expect(walk.current).to be_nil
    expect(walk.end?).to be true
  end

  it 'stays at the end' do
    8.times { walk.next! }
    expect(walk.end?).to be true
  end

  it 'should allow replacements' do
    2.times { walk.next! }
    walk.replace! H[:foo]
    6.times { walk.next! }
    expect(walk.result).to eql H[:ul, H[:p, H[:foo], H[:li, 'bar']]]
  end

  it 'should allow replacements' do
    7.times do
      walk.next!
      if !walk.end? && !walk.current.text? && walk.current.tag?(:li)
        walk.replace! H[:span, walk.current]
      end
    end

    expect(walk.result).to eql H[:ul,
                                 H[:p,
                                   H[:span, H[:li, 'foo', 'boo']],
                                   H[:span, H[:li, 'bar']]]]
  end


end
