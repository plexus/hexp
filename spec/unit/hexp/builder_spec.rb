require 'spec_helper'

describe Hexp::Builder do
  context 'with an empty block' do
    it 'should raise an exception' do
      expect { Hexp::Builder.new {}.to_hexp }.to raise_exception
    end
  end

  context 'with a tag and attributes passed to the constructor' do
    let(:builder) do
      Hexp::Builder.new :div, class: 'acatalectic'
    end
    it 'should use them as the root element' do
      expect(builder.to_hexp).to eq H[:div, class: 'acatalectic']
    end
  end

  context 'with a block parameter' do
    it 'should pass the builder to the block' do
      Hexp::Builder.new do |builder|
        expect(Hexp::Builder === builder).to be_true
      end
    end

    it 'should evaluate the block in the caller context' do
      this = self
      Hexp::Builder.new do |builder|
        expect(this).to eq self
      end
    end

    it 'should turn calls to the build object into elements' do
      hexp = Hexp::Builder.new do |builder|
        builder.div class: 'jintishi' do
          builder.br
        end
      end.to_hexp
      expect(hexp).to eq(H[:div, {class: 'jintishi'}, H[:br]])
    end
  end

  context 'without a block parameter' do
    it 'should evaluate in the context of the builder' do
      this = self
      Hexp::Builder.new do
        this.expect(::Hexp::Builder === self).to this.be_true
      end
    end

    it 'should turn bare method calls into elements' do
      hexp = Hexp::Builder.new do
        span do
          p({class: 'lyrical'}, "I'm with you in Rockland")
        end
      end.to_hexp
      expect(hexp).to eq(H[:span, H[:p, {class: 'lyrical'}, "I'm with you in Rockland"]])
    end
  end

  describe 'composing' do
    it 'should allow inserting Hexpable values with <<' do
      hexp = Hexp::Builder.new do
        div do |builder|
          builder << ::H[:span]
        end
      end.to_hexp
      expect(hexp).to eq(H[:div, H[:span]])
    end

    it 'should raise exception when inserting a non-hexp' do
      expect {
        Hexp::Builder.new {|b| b << Object.new }
      }.to raise_exception(Hexp::FormatError)
    end
  end

  describe Hexp::Builder::NodeBuilder do
    it 'lets you add CSS classes through method calls' do
      hexp = Hexp::Builder.new do
        div.milky.ponderous do
          blink 'My gracious, how wondrous'
        end
      end.to_hexp
      expect(hexp).to eq(H[:div, {class: 'milky ponderous'}, H[:blink, 'My gracious, how wondrous']])
    end
  end

  it 'should add text nodes with text!' do
    hexp = Hexp::Builder.new do
      div do
        text! 'Babyface, bijou, scharmninkel'
      end
    end.to_hexp
    expect(hexp).to eq(H[:div, 'Babyface, bijou, scharmninkel'])
  end

  it 'should return an inspection string' do
    expect(Hexp::Builder.new { div }.inspect).to eq "#<Hexp::Builder H[:div]>"
  end
end
