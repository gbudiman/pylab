class Ngram
  include Wizardry

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

  def self.query _x
    return Ngram.new(_x).pairs.map{ |k, v| v }.reduce(:+)
  end

private
  def pair _process:, _field:
    iterators = process_multi_syllables _process: _process

    iterators.each do |_hz|
      @pairs[_field].push({
        hanzi: _hz,
        pinyin: _hz.hanzi_get_pinyin,
        english: _hz.hanzi_get_english
      })
    end
  end

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
    pair _process: :hanzi, _field: :fuzzy_hanzi
  end

  def pair_fuzzy_pinyin
    pair _process: :pinyin, _field: :fuzzy_pinyin
  end

  def pair_english_to_hanzi
    pair _process: :english, _field: :fragment_english
  end

  def pair_partial_to_hanzi
    pair _process: :partial, _field: :partial_english
  end

  def process_multi_syllables _process:
    converter = lambda do |fn, x|
      case fn
      when :hanzi then return x.to_inverted_hanzi
      when :pinyin then return x.to_inverted_pinyin
      when :english then return x.to_inverted_english
      when :partial then return x.to_inverted_partial
      end
    end

    iterators = Array.new
    multi_syllable = @query.split( _process == :hanzi ? // : /\s+/ )

    if multi_syllable.length > 1
      fragments = Array.new

      multi_syllable.each do |syl|
        premap = $redis.smembers(converter.curry.(_process).curry.(syl))

        case _process
        when :partial
          fragment_container = Array.new
          premap.each do |word|
            fragment_container.push $redis.smembers(converter.curry.(:english).curry.(word))
          end

          fragments.push fragment_container.flatten
        else
          fragments.push premap
        end
      end

      iterators = fragments.first.dup
      fragments[1..-1].each do |frag|
        iterators = iterators & frag
      end
    else
      premap = $redis.smembers(converter.curry.(_process).curry.(@query))

      case _process
      when :partial
        premap.each do |word|
          iterators += $redis.smembers(converter.curry.(:english).curry.(word))
        end
      else
        iterators = premap
      end
    end

    return iterators
  end
end