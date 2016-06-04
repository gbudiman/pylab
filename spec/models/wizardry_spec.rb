require 'rails_helper'
include Wizardry

RSpec.describe Wizardry do
  context 'super-combinant' do
    before :each do
      @input = 'A1 ba1 la1 qi4 ya4'
    end

    it 'should list all combinations' do
      a = @input.split(/\s+/).length
      expected_length = a * (a + 1) / 2
      expect(@input.super_combination.length).to eq expected_length
    end

    it 'should not contain any tone' do
      @input.super_combination.each do |e|
        expect(e =~ /\d+/).to eq nil
      end
    end
  end
end