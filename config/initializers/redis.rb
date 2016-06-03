$redis = Redis::Namespace.new(:z, 
                              redis: Redis.new(host: 'localhost', 
                                               port: 6379))