class Ngram
  attr_reader :query, :pairs
  def initialize _x
    @query = _x
    @pairs = {
      exact_hanzi: Array.new,
      fuzzy_hanzi: Array.new,
      fragment_english: Array.new
    }

    make_pairs
  end

private
  def make_pairs
    pair_exact_hanzi_to_english
    pair_fuzzy_hanzi_to_english
    pair_english_to_hanzi
  end

  def pair_exact_hanzi_to_english
    if $redis.exists(@query.to_redis_ngram) 
      @pairs[:exact_hanzi].push({
        hanzi: @query,
        pinyin: $redis.hget(@query.to_redis_ngram, 'pinyin'),
        english: $redis.smembers(@query.to_redis_tmap).to_a
      })
    end
  end

  def pair_fuzzy_hanzi_to_english
    iterators = $redis.smembers(@query.to_inverted_ngram)

    #$redis.scan_each(match: Wizardry.ngram_scan(@query)).each do |ngram|
    iterators.each do |ngram|
      match = ngram.unredis_ngram
      $redis.smembers(match.to_redis_tmap).each do |t|
        @pairs[:fuzzy_hanzi].push({
          hanzi: match,
          pinyin: $redis.hget(match.to_redis_ngram, 'pinyin'),
          english: t
        })
      end
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