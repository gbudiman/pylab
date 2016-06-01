include Radical

module BuildingBlock
  def self.build
    loaded = Radical.load_file
    parents = Hash.new

    $redis.pipelined do
      loaded[:relations].each do |char, subcomps|
        $redis.sadd(char.to_redis_children, subcomps)

        subcomps.each do |subcomp|
          parents[subcomp.to_sym] ||= Set.new
          parents[subcomp.to_sym].add char
        end
      end

      parents.each do |subcomp, chars|
        $redis.sadd(subcomp.to_redis_parent, chars.to_a)
      end

      loaded[:roots].each do |root_char|
        $redis.sadd(Wizardry::PRECOMPUTED, root_char)
      end
    end
  end
end