require 'rails_helper'
include Wizardry

RSpec.describe Compressor do
  it 'should be able to efficiently generate keys' do
    k = Compressor.generate_keys 400000

    expect(k[0]).to eq 0x20.chr8
    expect(k[189]).to eq 0xFF.chr8
    expect(k[190]).to eq(0x20.chr8 + 0x20.chr8)
    expect(k.length).to eq(k.values.uniq.length)
  end

  it 'should summarize db usage' do
    Compressor.purge_keys
    Compressor.new

    unmatched_compression = 0
    $redis.scan_each(match: 'b:*').each do |c_key|
      if $redis.get(c_key) == nil
        unmatched_compression += 1
      end
    end

    expect(unmatched_compression).to eq 0
  end
end