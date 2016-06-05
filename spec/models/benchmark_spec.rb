require 'rails_helper'

RSpec.describe 'Query Benchmark' do
  before :all do
    @query = ['躲藏', '散', '云风',
              'release', 'camera release', 'influen', 'influe standi',
              'jiao', 'nan da xue', 'nandaxue', 'nan2 da4 xue2', 'hai nan2']
  end

  context 'result' do
    it 'should be non-zero' do
      @query.each do |q|
        expect(Ngram.query(q).length).to be > 0
      end
    end
  end

  context 'execution speed' do
    it 'should be monitored correctly' do
      puts
      capture = nil
      @query.each do |q|
        puts Benchmark.measure{ capture = Ngram.query(q) }.to_s.gsub(/[\r\n]/, '') \
           + " | " + sprintf("%4d", capture.length)
           + " | #{q}"
      end
    end
  end
end