require 'pry'

require 'rack/test'
RSpec.configure do |config|
  config.include Rack::Test::Methods
end

if ENV.has_key?('VCAP_SERVICES')
  puts "VCAP_SERVICES env set, not starting test redis-server"
else
  require 'support/redis_server'
  REDIS = RedisServer.new(
    host: "localhost",
    port: 6380,
    password: "p4ssw0rd"
  )

  RSpec.configure do |config|
    config.before(:suite) do
      REDIS.start
    end

    config.after(:suite) do
      REDIS.stop
    end
  end
end
