module Radical
  require 'wizardry'

  def self.load_file _path: Rails.root.join('db', 'seeds', 'radical.rb').to_s
    v_symbols = Set.new
    relations = Hash.new
    roots = Set.new

    $redis.pipelined do
      IO.foreach _path do |_l|
        char, comps = _l.gsub(/[\r\n\s]+/, '').split(/\,/)
        r_comps = comps.split(//)

        ([char] + r_comps).each do |x|
          v_symbols.add x
          #$redis.hsetnx x.to_redis_symbol, 'pinyin', ''
          #$redis.sadd Wizardry::SYMBOL_HASH, x
        end

        if char != comps
          relations[char.to_sym] = r_comps
        else
          roots.add char
        end
      end
    end

    $redis.sadd Wizardry::SYMBOL_HASH, v_symbols.to_a

    return {
      symbols: v_symbols.length,
      relations: relations,
      roots: roots
    }
  end

  def self.count
    return $redis.smembers(Wizardry::SYMBOL_HASH).count
  end
end