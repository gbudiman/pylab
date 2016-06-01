require 'rails_helper'
include Loader

RSpec.describe Loader do
  context 'Radical' do
    it 'should execute load properly' do
      Radical.load_file
    end
  end
end