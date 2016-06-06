class Lookahead
  include Wizardry 
  attr_reader :result

  REGEX_HANZI = /\p{Han}/
  REGEX_OTHER = /\A[\w\d]{3,}/

  def initialize _x
    @query = _x
    @result = nil

    case _x
    when REGEX_HANZI then lookahead_hanzi
    when REGEX_OTHER then lookahead_other
    end
  end

private
  def lookahead_hanzi
    @result = $redis.smembers(@query.to_inverted_hanzi)
  end

  def lookahead_other
    @result = $redis.smembers(@query.to_inverted_partial) 
  end
end