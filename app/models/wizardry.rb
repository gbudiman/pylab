class String
  def to_redis_symbol
    if self.length != 1
      raise RuntimeError, 
            "Symbol must be exactly one character\n" \
          + "Input: [#{self}]\n"
    end
    return "s:#{self}"
  end

  def to_redis_children
    return "c:#{self}"
  end

  def to_redis_parent
    return "p:#{self}"
  end
end

class Symbol
  def to_redis_children
    return "c:#{self.to_s}"
  end

  def to_redis_parent
    return "p:#{self.to_s}"
  end
end

module Wizardry
  PRECOMPUTED = 'precomp'
end