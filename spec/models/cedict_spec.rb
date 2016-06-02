require 'rails_helper'
include Loader

RSpec.describe Cedict do
  before :all do
    $redis.flushall
    Cedict.load_file
  end

  context 'parsing' do
    it 'should run correctly' do
      s = Ngram.new '考'
      t = Ngram.new 'flower'

      expect(s.pairs[:exact_hanzi].length).to eq 1
      expect(s.pairs[:fuzzy_hanzi].length).to be > 1

      expect(t.pairs[:exact_hanzi].length).to eq 0
      expect(t.pairs[:fuzzy_hanzi].length).to eq 0
      expect(t.pairs[:fragment_english].length).to be > 1
    end
  end
end