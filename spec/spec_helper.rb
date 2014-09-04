require 'app'
require 'rspec'
require 'rack/test'
require 'pry'

require 'support/redis_server'

REDIS = RedisServer.new(
  host: "localhost",
  port: 6380,
  password: "p4ssw0rd"
)

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    REDIS.start
  end

  config.after(:suite) do
    REDIS.stop
  end
end
