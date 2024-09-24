# initialize singleton redis connection
$redis = Redis.new(url: ENV["REDIS_URL"])
