class Array
  def super_combination
    result = Set.new
    (1..self.length).each do |dist|
      (0...self.length).each do |start|
        result.add (self[start...start+dist].join(''))
      end
    end

    return result
  end
end

class Fixnum
  def to_hanzi_compression_mapping
    return "#{Wizardry::HANZI_COMPRESSION_MAP}#{self}"
  end
end

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

  def to_redis_hanzi
    return "#{Wizardry::HANZI}#{self.gsub(Wizardry::HANZI, '')}"
  end

  def to_inverted_hanzi
    return "#{Wizardry::INVERTED_HANZI}#{self.gsub(Wizardry::INVERTED_HANZI, '')}"
  end

  def hanzi_get_pinyin
    return $redis.hget(self.to_redis_hanzi, Wizardry::HKEY_PINYIN)
  end

  def hanzi_get_english
    $redis.hget(self.to_redis_hanzi, Wizardry::HKEY_ENGLISH) \
          .split(/\//) \
          .reject { |x| x.blank? }
  end

  # def to_redis_ngram # (HASH)
  #   return "#{Wizardry::NGRAM}#{self}"
  # end

  # def to_inverted_ngram # (SET)
  #   return "#{Wizardry::INVERTED_NGRAM}#{self}"
  # end

  # def unredis_ngram 
  #   return self.gsub(Wizardry::NGRAM, '')
  # end

  # def to_redis_tmap # translation mapping Hanzi -> English (SET)
  #   return "t:#{self}"
  # end

  # def to_redis_english # English translation (SET)
  #   return "#{Wizardry::ENGLISH}#{self}"
  # end

  def to_inverted_english
    return "#{Wizardry::INVERTED_ENGLISH}#{self.gsub(Wizardry::INVERTED_ENGLISH, '')}"
  end

  # def unredis_english
  #   return self.gsub(Wizardry::ENGLISH, '')
  # end

  # def uninvert_english
  #   return self.gsub(Wizardry::INVERTED_ENGLISH, '')
  # end

  def to_inverted_pinyin
    return "#{Wizardry::INVERTED_PINYIN}#{self.gsub(Wizardry::INVERTED_PINYIN, '')}"
  end

  def to_inverted_partial
    return "#{Wizardry::INVERTED_PARTIAL}#{self.gsub(Wizardry::INVERTED_PARTIAL, '')}"
  end

  def super_combination
    toneless = self.gsub(/[^A-Za-z\ ]+/, '').downcase.split(/\s+/)
    return toneless.super_combination
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
  SYMBOL_HASH = 's:'
  HANZI = 'h:'
  ENGLISH = 'e:'
  INVERTED_HANZI = 'v:'
  INVERTED_PINYIN = 'w:'
  INVERTED_ENGLISH = 'x:'
  INVERTED_PARTIAL = 'y:'
  HKEY_PINYIN = 'p'
  HKEY_ENGLISH = 'e'
  HANZI_COMPRESSION_MAP = 'hcm:'

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