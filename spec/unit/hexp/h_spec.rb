require 'spec_helper'

describe 'H notation' do
  context 'if H is already defined' do
    before do
      @old_H = Object.send(:remove_const, :H)
      @old_stderr, $stderr = $stderr, StringIO.new
      ::H = 'foo'.freeze
    end

    after do
      Object.send(:remove_const, :H)
      $stderr = @old_stderr
      ::H = @old_H
    end

    it 'should not override H' do
      expect(H).to eq('foo')
    end

    it 'should print out a warning on STDERR' do
      load 'hexp/h.rb'
      expect($stderr.string).to match(/WARN/)
    end

  end

  context 'if H is not set yet' do
    before do
      Object.send(:remove_const, :H)
    end

    it 'should define H' do
      load 'hexp/h.rb'
      expect(H).to be_a Module
    end
  end
end
