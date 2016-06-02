class String
  def to_redis_symbol # (HASH)
    if self.length != 1
      raise RuntimeError, 
            "Symbol must be exactly one character\n" \
          + "Input: [#{self}]\n"
    end
    return "s:#{self}"
  end

  def to_redis_children # (SET)
    return "c:#{self}"
  end

  def to_redis_parent # (SET)
    return "p:#{self}"
  end

  def to_redis_ngram # (HASH)
    return "#{Wizardry::NGRAM}#{self}"
  end

  def to_inverted_ngram # (SET)
    return "#{Wizardry::INVERTED_NGRAM}#{self}"
  end

  def unredis_ngram 
    return self.gsub(Wizardry::NGRAM, '')
  end

  def to_redis_tmap # translation mapping Hanzi -> English (SET)
    return "t:#{self}"
  end

  def to_redis_english # English translation (SET)
    return "#{Wizardry::ENGLISH}#{self}"
  end

  def to_inverted_english
    return "#{Wizardry::INVERTED_ENGLISH}#{self}"
  end

  def unredis_english
    return self.gsub(Wizardry::ENGLISH, '')
  end

  def uninvert_english
    return self.gsub(Wizardry::INVERTED_ENGLISH, '')
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
  PRECOMPUTED_ROOT = 'precomp_root'
  NGRAM = 'n:'
  ENGLISH = 'e:'
  INVERTED_NGRAM = 'ni:'
  INVERTED_ENGLISH = 'ne:'

  def self.ngram_scan _x
    return "#{NGRAM}*#{_x}*"
  end

  def self.english_scan _x
    return "#{ENGLISH}*#{_x}*"
  end

  def self.english_prefixed_search _x
    return "#{INVERTED_ENGLISH}#{_x}*"
  end
end