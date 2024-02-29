# frozen_string_literal: true
require 'redis'

class SentinelClient
  def initialize(master_name, credentials)
    @client = Redis.new(
      host: credentials.fetch("host"),
      port: credentials.fetch("port"),
    )
    @master_name = master_name
  end

  def get_master_info
    @client.sentinel("master", @master_name)
  end

  def get_replicas_info
    @client.sentinel("replicas", @master_name)
  end

  def fail_over
    @client.sentinel("failover", @master_name)
  end
end

class RedisClient
  def initialize(credentials)
    Redis.new(
      host: credentials.fetch('host'),
      port: credentials.fetch('tls_port'),
      password: credentials.fetch('password'),
      timeout: 30
    )
  end

  def self.using_sentinel(credentials)
    Redis.new(
      host: credentials.fetch('master_name'),
      password: credentials.fetch('password'),
      sentinels: credentials.fetch('sentinels').map { | sentinel |  { host: sentinel["host"], port: sentinel["port"] } },
      timeout: 30
    )
  end

  def self.tls(credentials, version='')
    ssl_params = {
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
    if version.empty?
      ssl_params = {
        version: version,
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      }
    end

    Redis.new(
      host: credentials.fetch('host'),
      port: credentials.fetch('tls_port'),
      password: credentials.fetch('password'),
      ssl: true,
      ssl_params: ssl_params,
      timeout: 30
    )
  end
end
