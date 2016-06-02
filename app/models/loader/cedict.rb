module Cedict
  REGEX_COMMENT = /\A[\#\%]/
  REGEX_LINE = /\A([^\s]+)\s+([^\s]+)\s+\[([^\]]+)\]\s+(.+)/

  def self.load_file _path: Rails.root.join('db', 'seeds', 'cedict_ts.u8').to_s,
                     _verbosity: :progress_only
    processed = 0
    print 'CEDICT entry processed: 0' if _verbosity == :progress_only

    IO.foreach _path do |_l|
      next if _l =~ REGEX_COMMENT

      _l =~ REGEX_LINE
      traditional, simplified, pinyin, translations = $1, $2, $3, $4

      $redis.pipelined do
        update_redis _symbol: simplified, 
                     _pinyin: pinyin,
                     _translations: translations,
                     _verbosity: _verbosity
      end

      processed += 1
      if _verbosity == :progress_only
        report_progress(processed)
      end
    end

    return processed
  end

private
  def self.report_progress _x
    numeric_length = (_x - 1).to_s.length
    print "\b"*numeric_length
    print _x
  end

  def self.update_redis _symbol:, 
                        _pinyin:, 
                        _translations:, 
                        _break_on_exception: false,
                        _verbosity: :off # :off, :verbose

    if _symbol.split(//).length != _pinyin.split(/\s+/).length
      message = "Mismatched CEDICT entry length:\n" \
              + "  Hanzi:  [#{_symbol}]\n" \
              + "  Pinyin: [#{_pinyin}]"

      if _break_on_exception
        raise RuntimeError, message
      else
        case _verbosity
        when :verbose then puts message
        end
      end
    end

    translations = _translations.split(/\//).reject{ |x| x.blank? }

    # Update NGRAM
    $redis.mapped_hmset(_symbol.to_redis_ngram, { pinyin: _pinyin })
    $redis.sadd(_symbol.to_redis_tmap, translations)

    # Update NGRAM Inverted Indices
    _symbol.split(//).each do |_char|
      $redis.sadd(_char.to_inverted_ngram, _symbol)
    end

    translations.each do |t|
      $redis.sadd(t.to_redis_english, _symbol)

      # Update English Inverted Indices
      t.split(/\s+/).each do |word|
        (0...word.length).each do |_max|
          $redis.sadd(word[0.._max].to_inverted_english, t)
        end
        #$redis.sadd(word.to_inverted_english, t)
      end
    end
  end
end