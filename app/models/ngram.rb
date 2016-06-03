class Ngram
  attr_reader :query, :pairs
  def initialize _x
    @query = _x
    @pairs = {
      exact_hanzi: Array.new,
      fuzzy_hanzi: Array.new,
      fuzzy_pinyin: Array.new,
      fragment_english: Array.new
    }

    make_pairs
  end

private
  def make_pairs
    pair_exact_hanzi_to_english
    pair_fuzzy_hanzi_to_english
    # pair_fuzzy_pinyin
    # pair_english_to_hanzi
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
    iterators = $redis.smembers(@query.to_inverted_pinyin)

    iterators.each do |hanzi|
      @pairs[:fuzzy_pinyin].push({
        hanzi: hanzi,
        pinyin: $redis.hget(hanzi.to_redis_ngram, 'pinyin'),
        english: $redis.smembers(hanzi.to_redis_tmap).to_a
      })
    end
  end

  def pair_english_to_hanzi
    iterators = $redis.smembers(@query.to_inverted_english)

    #$redis.scan_each(match: Wizardry.english_scan(@query)).each do |fragment|
    iterators.each do |fragment|
      match = fragment.uninvert_english
      mandarin = Hash.new
      $redis.smembers(match.to_redis_english).each do |_hz|
        mandarin[_hz] = $redis.hget(_hz.to_redis_ngram, 'pinyin')
      end

      @pairs[:fragment_english].push({
        english: match,
        mandarin: mandarin
      })
    end
  end
end