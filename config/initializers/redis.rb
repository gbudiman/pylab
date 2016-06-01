$redis = Redis::Namespace.new(:pylab, 
                              redis: Redis.new(host: 'localhost', 
                                               port: 6379))