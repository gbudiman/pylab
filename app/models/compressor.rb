class Compressor
  K = (0x20..0x7E).to_a + (0xA0..0xAC).to_a + (0xAE..0xFF).to_a

  def initialize
    @stat = Hash.new
    @referential_frequency = Hash.new(0)
    @dict = Hash.new
    compute_hanzi_keyspace
    compute_inverted_hanzi
    compute_inverted_pinyin

    ap @stat
    Hash[@referential_frequency.sort_by{ |k, v| -v}].each_with_index do |(hz, f), i|
      compressed_id = Compressor.slash_bits(i)
      $redis.set("b:#{compressed_id}", hz)
      @dict[hz] = compressed_id
    end

    execute_compression
  end

  def execute_compression
    puts "Compressing Hanzi"
    @dict.each do |hz, compressed|
      $redis.rename("#{Wizardry::HANZI}#{hz}", "#{Wizardry::HANZI}#{compressed}")
    end

    [Wizardry::INVERTED_HANZI,
     Wizardry::INVERTED_PINYIN,
     Wizardry::INVERTED_ENGLISH].each do |x|
      print "Compressing #{x}: 0"
      $redis.scan_each(match: "#{x}*").each_with_index do |k, i|
        report_progress(i+1)
        members = $redis.smembers(k).dup

        members.each do |m|
          $redis.srem(k, m)
          $redis.sadd(k, @dict[m])
        end
      end

      puts
    end
  end

  def report_progress _x
    p = (_x - 1).to_s.length
    print "\b"*p
    print _x
  end

  def self.generate_keys _n
    keys = Hash.new
    (0.._n).each do |n|
      keys[n] = slash_bits n
    end

    return keys
  end

  def self.purge_keys
    $redis.scan_each(match: 'b:*') do |key|
      $redis.del(key)
    end
  end

  def self.slash_bits _x
    x = _x
    sb = ''

    begin
      case sb.length
      when 0 then sb = K[x % K.length].chr8 + sb
      else sb = K[x % K.length-1].chr8 + sb
      end

      x = x / (K.length)
    end while x > 0

    return sb
  end

private
  def compute_hanzi_keyspace
    e_count = 0
    hz_count = 0
    $redis.scan_each(match: "#{Wizardry::HANZI}*").each do |k|
      hz_count += k[2..-1].length
      e_count += 1
    end

    @stat[:hz_character_count] = hz_count
    @stat[:hz_entry_count] = e_count
  end

  def compute_inverted_hanzi
    e_count = 0
    ih_count = 0
    hz_count = 0

    $redis.scan_each(match: "#{Wizardry::INVERTED_HANZI}*").each do |ih|
      e_count += 1
      $redis.smembers(ih).each do |el|
        ih_count += 1
        hz_count += el.length
        @referential_frequency[el] += 1
      end
    end

    @stat[:ih_entry_count] = e_count
    @stat[:ih_element_count] = ih_count
    @stat[:ih_character_count] = hz_count
  end

  def compute_inverted_pinyin
    e_count = 0
    ip_count = 0
    hz_count = 0

    $redis.scan_each(match: "#{Wizardry::INVERTED_PINYIN}*").each do |ip|
      e_count += 1
      $redis.smembers(ip).each do |el|
        ip_count += 1
        hz_count += el.length
        @referential_frequency[el] += 1
      end
    end

    @stat[:ip_entry_count] = e_count
    @stat[:ip_element_count] = ip_count
    @stat[:ip_character_count] = hz_count
  end

  def compute_inverted_english
    e_count = 0
    ip_count = 0
    hz_count = 0

    $redis.scan_each(match: "#{Wizardry::INVERTED_ENGLISH}*").each do |ie|
      e_count += 1
      $redis.smembers(ie).each do |el|
        ie_count += 1
        hz_count += el.length
        @referential_frequency[el] += 1
      end

    @stat[:ip_entry_count] = e_count
    @stat[:ip_element_count] = ip_count
    @stat[:ip_character_count] = hz_count
    end
  end
end