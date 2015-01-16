require 'sinatra'
require 'redis'
require 'cf-app-utils'

before do
  unless redis_credentials
    halt(500, %{
You must bind a Redis service instance to this application.

You can run the following commands to create an instance and bind to it:

  $ cf create-service p-redis development redis-instance
  $ cf bind-service <app-name> redis-instance})
  end
end

put '/:key' do
  data = params[:data]
  if data
    redis_client.set(params[:key], data)
    status 201
    body 'success'
  else
    status 400
    body 'data field missing'
  end
end

get '/:key' do
  value = redis_client.get(params[:key])
  if value
    status 200
    body value
  else
    status 404
    body 'key not present'
  end
end

delete '/:key' do
  result = redis_client.del(params[:key])
  if result > 0
    status 410 
    body 'success'
  else
    status 404
    body 'key not present'
  end
end

def redis_credentials
  if ENV['VCAP_SERVICES']
    all_pivotal_redis_credentials = CF::App::Credentials.find_all_by_all_service_tags(['redis', 'pivotal'])
    all_pivotal_redis_credentials && all_pivotal_redis_credentials.first
  end
end

def redis_client
  @client ||= Redis.new(
    host: redis_credentials.fetch('host'),
    port: redis_credentials.fetch('port'),
    password: redis_credentials.fetch('password')
  )
end
