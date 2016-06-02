class Hanzi
  attr_reader :char, :used_by, :components

  def initialize _x
    if _x.length != 1
      raise RuntimeError, 
            "Hanzi must be initialied with exactly one character\n" \
          + "Input: #{_x}"
    end

    @char = _x
    @used_by = Hanzi.super_components(@char)
    @components = Hanzi.sub_components(@char)
  end

  def self.sub_components _x
    return $redis.smembers(_x.to_redis_children)
  end

  def self.super_components _x
    return $redis.smembers(_x.to_redis_parent)
  end

  def self.roots
    return $redis.smembers(Wizardry::PRECOMPUTED_ROOT)
  end

  def self.leafs
  end
end