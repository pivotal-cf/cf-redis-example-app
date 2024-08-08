# frozen_string_literal: true
require 'redis'
require_relative 'redis_tls'

class ClientRedis
  def initialize
  end

  def self.default(credentials)
    Redis.new(
      host: credentials.fetch('host'),
      port: credentials.fetch('port'),
      password: credentials.fetch('password'),
      timeout: 30
    )
  end

  def self.using_sentinel(credentials)
      Redis.new(
        name: credentials.fetch('master_name'),
        password: credentials.fetch('password'),
        sentinel_password: credentials.fetch('sentinel_password'),
        sentinels: credentials.fetch('sentinels').map { | sentinel |  { host: sentinel["host"], port: sentinel["port"] } },
        timeout: 30
      )
    end

  def self.tls_using_sentinel(credentials, version='')
    if version.include?("TLSv1_3")
      master_redis = SentinelTLS13.new(
        host: credentials.fetch('sentinels').first['host'],
        port: credentials.fetch('sentinels').first['tls_port'],
        sentinel_password: credentials.fetch("sentinel_password"),
        master_name: credentials.fetch('master_name')
      ).get_redis_instance
      return @client_tls_13 ||= RedisTLS13.new(
        host: master_redis[0],
        port: master_redis[1],
        password: credentials.fetch('password')
      )
    else
      ssl_params = {
        ca_file: "/etc/ssl/certs/ca-certificates.crt",
        ssl_version: version,
      }
      if version.empty?
        ssl_params = {
          ca_file: "/etc/ssl/certs/ca-certificates.crt"
        }
      end
      Redis.new(
        name: credentials.fetch('master_name'),
        password: credentials.fetch('password'),
        sentinel_password: credentials.fetch('sentinel_password'),
        sentinels: credentials.fetch('sentinels').map { | sentinel |  { host: sentinel["host"], port: sentinel["tls_port"] } },
        ssl: true,
        ssl_params: ssl_params,
        timeout: 30
      )
    end
  end

  def self.tls(credentials, version='')
    ssl_params = {
      ca_file: "/etc/ssl/certs/ca-certificates.crt",
      ssl_version: version,
    }

    if version.empty?
      ssl_params = {
        ca_file: "/etc/ssl/certs/ca-certificates.crt"
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
