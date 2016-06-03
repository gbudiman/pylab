require 'rails_helper'
include Loader

RSpec.describe Cedict do
  # before :suite do
  #   $redis.flushall
  #   Cedict.new
  # end

  shared_examples 'proper pair' do
    it 'should have content in hanzi/pinyin/english' do
      q.each do |r|
        expect(r[:hanzi].blank?).to eq false
        expect(r[:pinyin].blank?).to eq false
        expect(r[:english].count).to be > 0

        r[:english].each do |eng|
          expect(eng.blank?).to eq false
        end
      end
    end
  end

  context 'searches' do
    context 'hanzi' do
      before :each do
        s = Ngram.new '搜'
        @p = s.pairs
      end

      context 'exact result' do
        it_should_behave_like 'proper pair' do
          let(:q) { @p[:exact_hanzi] }
        end
      end

      context 'fuzzy result' do
        it 'should be non-zero' do
          expect(@p[:fuzzy_hanzi].length).to be > 0
        end

        it_should_behave_like 'proper pair' do
          let(:q) { @p[:fuzzy_hanzi] }
        end
      end
    end
    # it 'should return value correctly' do
    #   # s = Ngram.new '考'
    #   # t = Ngram.new 'flower'
    #   p0 = Ngram.new 'shisheng'
    #   p1 = Ngram.new 'shishe'

    #   ap p0.pairs
    #   ap p1.pairs

    #   # expect(s.pairs[:exact_hanzi].length).to eq 1
    #   # expect(s.pairs[:fuzzy_hanzi].length).to be > 1

    #   # expect(t.pairs[:exact_hanzi].length).to eq 0
    #   # expect(t.pairs[:fuzzy_hanzi].length).to eq 0
    #   # expect(t.pairs[:fragment_english].length).to be > 1
    # end
  end
end