require 'spec_helper'

describe Hexp::DSL do
  let(:jotie) { 'Liefste, Hart en woorden houden voor jou stil' }
  let(:hexpable) do
    Class.new do
      include Hexp::DSL

      def initialize(klz, words)
        @class, @words = klz, words
      end

      def to_hexp
        H[:div, {class: @class}, [@words]]
      end
    end.new('prinses', jotie)
  end

  {
    tag: :div,
    attributes: {'class' => 'prinses'},
    children: ['Liefste, Hart en woorden houden voor jou stil'],
    to_html: "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n<div class=\"prinses\">Liefste, Hart en woorden houden voor jou stil</div>\n"
  }.each do |method, result|
    it "should delegate `#{method}' to to_hexp" do
      expect(hexpable.public_send(method)).to eq(result)
    end
  end

  it "should delegate `attr' to to_hexp" do
    expect(hexpable.attr('class')).to eq('prinses')
    expect(hexpable.attr('class', 'scharminkel')).to eq(
      H[:div, {class: 'scharminkel'}, [jotie]]
    )
  end

  it "should delegate `select' to to_hexp" do
    expect(hexpable.select{|el| el.text?}.to_a).to eq([jotie])
  end

  it "should delegate `class?' to to_hexp" do
    expect(hexpable.class?(:prinses)).to be_true
    expect(hexpable.class?(:prins)).to be_false
  end

  it "should delegate `rewrite' to to_hexp" do
    expect(hexpable.rewrite {|el| 'De liefde speelt me parten' if el.text?}.to_hexp)
      .to eq H[:div, {class: 'prinses'}, ['De liefde speelt me parten']]
  end

end
