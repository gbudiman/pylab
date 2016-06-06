require 'rake'

namespace :system do
  task rebuild: :environment do
    include Loader
    $redis.flushall
    BuildingBlock.build
    Cedict.new
  end
end
