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

  def self.tls(credentials, version='')
    ssl_params = {
      verify_mode: OpenSSL::SSL::VERIFY_NONE,
      ssl_version: version,
    }

    if version.empty?
      ssl_params = {
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
