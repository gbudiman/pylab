require 'rails_helper'

RSpec.describe Lookahead do
  context 'providing suggestion' do
    it 'should provide hanzi suggestions correctly' do
      expect(Lookahead.new('看').result.length).to be > 0
    end

    it 'should provide non-hanzi suggestions correctly' do
      expect(Lookahead.new('train').result.length).to be > 0
    end
  end
end