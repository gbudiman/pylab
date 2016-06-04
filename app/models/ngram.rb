class Ngram
  attr_reader :query, :pairs
  def initialize _x
    @query = _x
    @pairs = {
      exact_hanzi: Array.new,
      fuzzy_hanzi: Array.new,
      fuzzy_pinyin: Array.new,
      fragment_english: Array.new,
      partial_english: Array.new
    }

    make_pairs
  end

private
  def make_pairs
    pair_exact_hanzi_to_english
    pair_fuzzy_hanzi_to_english
    pair_fuzzy_pinyin
    pair_english_to_hanzi
    pair_partial_to_hanzi
  end

  def pair_exact_hanzi_to_english
    key = @query.to_redis_hanzi

    if $redis.exists(key) 
      @pairs[:exact_hanzi].push({
        hanzi: @query,
        pinyin: key.hanzi_get_pinyin,
        english: key.hanzi_get_english
      })
    end
  end

  def pair_fuzzy_hanzi_to_english
    iterators = $redis.smembers(@query.to_inverted_hanzi)

    iterators.each do |_hz|
      @pairs[:fuzzy_hanzi].push({
        hanzi: _hz,
        pinyin: _hz.hanzi_get_pinyin,
        english: _hz.hanzi_get_english
      })
    end
  end

  def pair_fuzzy_pinyin
    iterators = process_multi_syllables _process: :pinyin

    iterators.each do |_hz|
      @pairs[:fuzzy_pinyin].push({
        hanzi: _hz,
        pinyin: _hz.hanzi_get_pinyin,
        english: _hz.hanzi_get_english
      })
    end
  end

  def pair_english_to_hanzi
    iterators = process_multi_syllables _process: :english

    iterators.each do |_hz|
      @pairs[:fragment_english].push({
        hanzi: _hz,
        pinyin: _hz.hanzi_get_pinyin,
        english: _hz.hanzi_get_english
      })
    end
  end

  def pair_partial_to_hanzi
    iterators = $redis.smembers(@query.to_inverted_partial)

    iterators.each do |fragment|
      $redis.smembers(fragment.to_inverted_english).each do |_hz|
        @pairs[:partial_english].push({
          hanzi: _hz,
          pinyin: _hz.hanzi_get_pinyin,
          english: _hz.hanzi_get_english
        })
      end
    end
  end

  def process_multi_syllables _process:
    converter = lambda do |fn, x|
      case fn
      when :pinyin then return x.to_inverted_pinyin
      when :english then return x.to_inverted_english
      when :partial then return x.to_inverted_partial
      end
    end
    iterators = Array.new
    multi_syllable = @query.split(/\s+/)

    if multi_syllable.length > 1
      fragments = Array.new

      multi_syllable.each do |syl|
        fragments.push $redis.smembers(converter.curry.(_process).curry.(syl))
      end

      iterators = fragments.first.dup
      fragments[1..-1].each do |frag|
        iterators = iterators & frag
      end
    else
      iterators = $redis.smembers(converter.curry.(_process).curry.(@query))
    end

    return iterators
  end
end