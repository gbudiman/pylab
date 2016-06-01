require 'rails_helper'
include Loader

RSpec.describe Loader do
  before :all do
    $redis.flushall
  end

  context 'Radical' do
    it 'should execute load properly' do
      loaded = Radical.load_file
      keys_in_redis = Radical.count

      expect(loaded[:symbols]).to eq keys_in_redis
      expect(loaded[:symbols]).to be > 0
    end
  end

  context 'Building Block' do
    before :all do
      BuildingBlock.build
    end

    context 'functionality' do
      it 'should build relations correctly' do
        mo = Hanzi.new '默'
        you = Hanzi.new '又'

        expect(mo.used_by.length).to eq 0
        expect(mo.components.length).to be > 0

        expect(you.used_by.length).to be > 0
        expect(you.components.length).to eq 0
      end

      it 'should be able to find characters without subcomponents' do
        expect(Hanzi.roots.length).to be > 0
      end
    end
  end
end