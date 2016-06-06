require 'rails_helper'
include Wizardry

RSpec.describe SearchesController, type: :controller do
  context 'dictionary query' do
    it 'should return result from dictionary' do
      get :dictionary, q: '龙'
      expect(JSON.parse(response.body).length).to be > 0
    end
  end

  context 'structural query' do
    it 'should correctly process character that only have components' do
      get :structural, q: '警'
      expect((JSON.parse(response.body))['used_by'].length).to eq 0
      expect((JSON.parse(response.body))['components'].length).to be > 0
    end

    it 'should correctly process character that have both components and parents' do
      get :structural, q: '并'
      expect((JSON.parse(response.body))['used_by'].length).to be > 0
      expect((JSON.parse(response.body))['components'].length).to be > 0
    end

    it 'should correctly process character that have both components and parents' do
      get :structural, q: '一'
      expect((JSON.parse(response.body))['used_by'].length).to be > 0
      expect((JSON.parse(response.body))['components'].length).to eq 0
    end
  end
end
