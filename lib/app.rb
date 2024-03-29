require 'sinatra'
require 'redis'
require 'cf-app-utils'
require_relative 'redis_tls'
require_relative 'client'

before do
  unless redis_credentials
    halt(500, %{
You must bind a Redis service instance to this application.

You can run the following commands to create an instance and bind to it:

  $ cf create-service p-redis development redis-instance
  $ cf bind-service <app-name> redis-instance})
  end
end

get '/master' do
  value = sentinel_client.get_master_info.to_json
  if value
    status 200
    body value
  else
    status 400
    body 'something went wrong'
  end
end

get '/replicas' do
  value = sentinel_client.get_replicas_info.to_json
  if value
    status 200
    body value
  else
    status 400
    body 'something went wrong'
  end
end

get '/failover' do
  value = sentinel_client.fail_over.to_json
  if value
    status 200
    body value
  else
    status 400
    body 'something went wrong'
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

get '/status/health' do
  status 200
  body 'app is running'
end

get '/config/:item' do
  unless params[:item]
    status 400
    body 'USAGE: GET /config/:item'
    return
  end

  value = redis_client.config('get', params[:item])
  if value.length < 2
    status 404
    body "config item #{params[:item]} not found"
    return
  end

  status 200
  body value[1]
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

get '/tls/v1/:key' do
  get_key_with_tls_version(params[:key], 'TLSv1')
end

get '/tls/v1.1/:key' do
  get_key_with_tls_version(params[:key], 'TLSv1_1')
end

get '/tls/v1.2/:key' do
  get_key_with_tls_version(params[:key], 'TLSv1_2')
end

get '/tls/v1.3/:key' do
  get_key_with_tls_version(params[:key], 'TLSv1_3')
end

def get_key_with_tls_version(key, version)
  begin
    value = redis_client_tls(version).get(key)
    if value
      status 200
      body value
    else
      status 404
      body 'key not present'
    end
  rescue StandardError => e
      status 418
      body 'protocol not supported: '+e.message
  end
end

def redis_client_tls(version='TLSv1')
  if redis_credentials.key?('sentinels')
      @client ||= RedisClient.tls_using_sentinel(redis_credentials, version)
  else
    if version == 'TLSv1_3'
      return @client_tls_13 ||= RedisTLS13.new(
        host: redis_credentials.fetch('host'),
        port: redis_credentials.fetch('tls_port'),
        password: redis_credentials.fetch('password')
      )
    end
    @client ||= RedisClient.tls(redis_credentials, version)
  end
end

def sentinel_client
  @sentinel_client ||= SentinelClient.new(redis_credentials.fetch("master_name"), redis_credentials.fetch("sentinels").first)
end

def redis_client
  tls_enabled = ENV['tls_enabled'] || false

  if redis_credentials.key?('sentinels')
    if tls_enabled
      @client ||= RedisClient.tls_using_sentinel(redis_credentials, version='TLSv1_2')
    else
      @client ||= RedisClient.using_sentinel(redis_credentials)
    end
  elsif tls_enabled
    @client ||= RedisClient.tls(redis_credentials)
  else
    @client ||= RedisClient.default(redis_credentials)
  end
end

def redis_credentials
  service_name = ENV['service_name'] || "redis"

  if ENV['VCAP_SERVICES']
    all_pivotal_redis_credentials = CF::App::Credentials.find_all_by_all_service_tags(['redis', 'pivotal'])
    if all_pivotal_redis_credentials && all_pivotal_redis_credentials.first
      all_pivotal_redis_credentials && all_pivotal_redis_credentials.first
    else
      redis_service_credentials = CF::App::Credentials.find_by_service_name(service_name)
      redis_service_credentials
    end
  end
end
