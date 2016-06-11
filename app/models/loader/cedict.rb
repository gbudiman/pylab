class Cedict
  DEFAULT_CEDICT_PATH = Rails.root.join('db', 'seeds', 'cedict_ts.u8').to_s
  REGEX_COMMENT = /\A[\#\%]/
  REGEX_LINE = /\A([^\s]+)\s+([^\s]+)\s+\[([^\]]+)\]\s+(.+)/

  def initialize _path: DEFAULT_CEDICT_PATH, _verbosity: :progress_only
    @processed = 0
    @path = _path
    @verbosity = _verbosity
    @hanzi_inverted = Hash.new

    parse_file
  end

  def parse_file
    print 'CEDICT entry processed: 0'

    IO.foreach @path do |_l|
      next if _l =~ REGEX_COMMENT

      _l =~ REGEX_LINE
      traditional, simplified, pinyin, english = $1, $2, $3, $4

      update_redis _hanzi: simplified,
                   _pinyin: pinyin.gsub(/u\:/, 'v'),
                   _english: english

      @processed += 1
      report_progress
    end

    puts
  end

  # def self.load_file _path: DEFAULT_CEDICT_PATH, _verbosity: :progress_only
  #   processed = 0
  #   print 'CEDICT entry processed: 0' if _verbosity == :progress_only

  #   IO.foreach _path do |_l|
  #     next if _l =~ REGEX_COMMENT

  #     _l =~ REGEX_LINE
  #     traditional, simplified, pinyin, translations = $1, $2, $3, $4

  #     $redis.pipelined do
  #       update_redis _symbol: simplified, 
  #                    _pinyin: pinyin,
  #                    _translations: translations,
  #                    _verbosity: _verbosity
  #     end

  #     processed += 1
  #     if _verbosity == :progress_only
  #       report_progress(processed)
  #     end
  #   end

  #   return processed
  # end

private

  def update_redis _hanzi:, _pinyin:, _english:
    data = { hanzi: _hanzi, pinyin: _pinyin, english: _english }
    update_hanzi_entry data
    update_inverted_hanzi data
    update_inverted_pinyin data
    update_inverted_english data
  end

  def update_hanzi_entry _d
    $redis.mapped_hmset(_d[:hanzi].to_redis_hanzi,
                        {
                          p: _d[:pinyin],
                          e: _d[:english]
                        })
  end

  def update_inverted_hanzi _d
    return if _d[:hanzi].length == 1

    _d[:hanzi].split(//).reject{ |x| x =~ /[a-z0-9、·，]+/i }.each do |hz|
      $redis.sadd(hz.to_inverted_hanzi, _d[:hanzi])
    end
  end

  def update_inverted_pinyin _d
    _d[:pinyin].split(/\s+/).select{ |x| x =~ /[a-z1-5]+/i }.each do |py|
      $redis.sadd(py.downcase.to_inverted_pinyin, _d[:hanzi])
    end

    _d[:pinyin].super_combination.each do |sc|
      $redis.sadd(sc.to_inverted_pinyin, _d[:hanzi])
    end

    #$redis.sadd(_d[:pinyin].gsub(/[\d\s]+/, '').downcase.to_inverted_pinyin, _d[:hanzi])
  end

  def update_inverted_english _d
    _d[:english].split(/\//).reject{ |x| x.blank? }.each do |entries|
      entries.split(/\s+/).each do |word|
        rudimentary = word.gsub(/[^A-Za-z0-9]+/, '')
        next if rudimentary.blank?

        $redis.sadd(rudimentary.downcase.to_inverted_english, _d[:hanzi])

        if rudimentary =~ /\A[a-z]+\z/i
          (0...rudimentary.length-1).each do |max|
            partial = rudimentary[0..max]
            $redis.sadd(partial.downcase.to_inverted_partial, rudimentary.downcase)
          end
        end
      end
    end
  end

  def report_progress
    numeric_length = (@processed - 1).to_s.length
    print "\b"*numeric_length
    print @processed
  end

  # def self.update_redis _symbol:, 
  #                       _pinyin:, 
  #                       _translations:, 
  #                       _break_on_exception: false,
  #                       _verbosity: :off # :off, :verbose

  #   if _symbol.split(//).length != _pinyin.split(/\s+/).length
  #     message = "Mismatched CEDICT entry length:\n" \
  #             + "  Hanzi:  [#{_symbol}]\n" \
  #             + "  Pinyin: [#{_pinyin}]"

  #     if _break_on_exception
  #       raise RuntimeError, message
  #     else
  #       case _verbosity
  #       when :verbose then puts message
  #       end
  #     end
  #   end

  #   translations = _translations.split(/\//).reject{ |x| x.blank? }
  #   pinyin = _pinyin.split(/\s+/)

  #   # Update NGRAM
  #   $redis.mapped_hmset(_symbol.to_redis_ngram, { pinyin: _pinyin })
  #   $redis.sadd(_symbol.to_redis_tmap, translations)

  #   # Update NGRAM Inverted Indices
  #   # _symbol.split(//).each do |_char|
  #   #   $redis.sadd(_char.to_inverted_ngram, _symbol)
  #   # end

  #   translations.each do |t|
  #     $redis.sadd(t.to_redis_english, _symbol)

  #     # Update English Inverted Indices
  #     # t.split(/\s+/).each do |word|
  #     #   (0...word.length).each do |_max|
  #     #     $redis.sadd(word[0.._max].to_inverted_english, t)
  #     #   end
  #     #   #$redis.sadd(word.to_inverted_english, t)
  #     # end
  #   end

  #   # Update pinyin inverted indices
  #   # pinyin.each do |p|
  #   #   (0...p.length).each do |_max|
  #   #     $redis.sadd(p[0.._max].to_inverted_pinyin, _symbol)
  #   #   end
  #   # end

  #   # toneless = _pinyin.gsub(/[\d\s]+/, '')
  #   # (0...toneless.length).each do |_max|
  #   #   $redis.sadd(toneless[0.._max].to_inverted_pinyin, _symbol)
  #   # end
  # end
end