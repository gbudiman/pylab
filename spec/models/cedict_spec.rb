require 'rails_helper'
include Loader

RSpec.describe Cedict do
  before :all do
    $redis.flushall
    Cedict.new
  end

  shared_examples 'non-null result' do
    it 'should return non-zero result' do
      expect(q.length).to be > 0
    end
  end

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

  shared_examples 'wildcarded search result' do
    it 'should contain specific result' do
      result = Array.new

      case field
      when :english
        q.each do |r|
          result = result + r[field]
        end
      else
        q.each do |r|
          result.push r[field]
        end
      end

      result_inclusion = result.include? seek
      if !result_inclusion
        raise RuntimeError, "Field :#{field} does not contain value \"#{seek}\""
      end

      expect(result_inclusion).to eq true
    end
  end

  context 'searches' do
    context 'hanzi' do
      before :each do
        s = Ngram.new '亚'
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

        it_should_behave_like 'wildcarded search result' do
          let(:q)      { @p[:fuzzy_hanzi] }
          let(:field)  { :hanzi }
          let(:seek)   { '阿巴拉契亚' }
        end
      end
    end

    context 'hanzi multi-syllable' do
      ['快速', '电子邮件'].each do |x|
        it_should_behave_like 'non-null result' do
          let(:q) { Ngram.new(x).pairs[:exact_hanzi] }
        end

        it_should_behave_like 'proper pair' do
          let(:q) { Ngram.new(x).pairs[:exact_hanzi] }
        end

        it_should_behave_like 'wildcarded search result' do
          let(:q)      { Ngram.new(x).pairs[:exact_hanzi] }
          let(:field)  { :hanzi }
          let(:seek)   { x }
        end
      end
    end

    context 'toneless pinyin' do
      before :each do
        s = Ngram.new 'ke'
        @p = s.pairs
      end

      context 'fuzzy result' do
        it_should_behave_like 'non-null result' do
          let(:q) { @p[:fuzzy_pinyin] }
        end

        it_should_behave_like 'proper pair' do
          let(:q) { @p[:fuzzy_pinyin] }
        end

        it_should_behave_like 'wildcarded search result' do
          let(:q)      { @p[:fuzzy_pinyin] }
          let(:field)  { :pinyin }
          let(:seek)   { 'ke2 sou5' }
        end
      end
    end

    context 'toneless pinyin non-starter' do
      before :each do
        s = Ngram.new 'sou'
        @p = s.pairs
      end

      context 'fuzzy result' do
        it_should_behave_like 'non-null result' do
          let(:q) { @p[:fuzzy_pinyin] }
        end

        it_should_behave_like 'proper pair' do
          let(:q) { @p[:fuzzy_pinyin] }
        end

        it_should_behave_like 'wildcarded search result' do
          let(:q)      { @p[:fuzzy_pinyin] }
          let(:field)  { :pinyin }
          let(:seek)   { 'ke2 sou5' }
        end
      end
    end

    context 'pinyin non-starter' do
      before :each do
        s = Ngram.new 'sou5'
        @p = s.pairs
      end

      context 'fuzzy result' do
        it_should_behave_like 'non-null result' do
          let(:q) { @p[:fuzzy_pinyin] }
        end

        it_should_behave_like 'proper pair' do
          let(:q) { @p[:fuzzy_pinyin] }
        end

        it_should_behave_like 'wildcarded search result' do
          let(:q)      { @p[:fuzzy_pinyin] }
          let(:field)  { :pinyin }
          let(:seek)   { 'ke2 sou5' }
        end
      end
    end

    context 'pinyin multi-syllable' do
      ['paiqiu', 'pai2 qiu2', 'pai qiu'].each do |x|
        it_should_behave_like 'non-null result' do
          let(:q) { Ngram.new(x).pairs[:fuzzy_pinyin] }
        end

        it_should_behave_like 'proper pair' do
          let(:q) { Ngram.new(x).pairs[:fuzzy_pinyin] }
        end

        it_should_behave_like 'wildcarded search result' do
          let(:q)      { Ngram.new(x).pairs[:fuzzy_pinyin] }
          let(:field)  { :pinyin }
          let(:seek)   { 'pai2 qiu2' }
        end
      end
    end

    context 'english fragment' do
      ['flower', 'flower pot'].each do |x|
        it_should_behave_like 'non-null result' do
          let(:q) { Ngram.new(x).pairs[:fragment_english] }
        end

        it_should_behave_like 'proper pair' do
          let(:q) { Ngram.new(x).pairs[:fragment_english] }
        end

        it_should_behave_like 'wildcarded search result' do
          let(:q)      { Ngram.new(x).pairs[:fragment_english] }
          let(:field)  { :english }
          let(:seek)   { x }
        end
      end
    end

    context 'english partial' do
      before :each do
        s = Ngram.new 'holo'
        @p = s.pairs
      end

      context 'fuzzy result' do
        it_should_behave_like 'non-null result' do
          let(:q) { @p[:partial_english] }
        end

        it_should_behave_like 'proper pair' do
          let(:q) { @p[:partial_english] }
        end

        it_should_behave_like 'wildcarded search result' do
          let(:q)      { @p[:partial_english] }
          let(:field)  { :english }
          let(:seek)   { 'hologram' }
        end
      end
    end
  end
end