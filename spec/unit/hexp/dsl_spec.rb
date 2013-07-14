require 'spec_helper'

describe Hexp::DSL do
  context 'when included in a class' do
    let (:hexpable) do
      Class.new do
        include Hexp::DSL
        def to_hexp
          @stub ||= Object.new
        end
      end.new
    end

    it 'should delegate calls of DSL methods to to_hexp' do
      expect(hexpable.to_hexp).to receive(:to_html)
      hexpable.to_html
    end
  end
end
