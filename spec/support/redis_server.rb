require "childprocess"

class RedisServer
  attr_reader :host, :port, :password, :tls_port

  def initialize(options)
    @host = options.fetch(:host)
    @port = options.fetch(:port)
    @tls_port = options.fetch(:tls_port)
    @password = options.fetch(:password)

    @process = ChildProcess.build("redis-server",
                                  "--port", port.to_s,
                                  "--requirepass", password,
                                  "--tls-port", tls_port.to_s,
                                  "--tls-cert-file", "#{__dir__}/redis.crt",
                                  "--tls-key-file", "#{__dir__}/redis.key",
                                  "--tls-ca-cert-file", "#{__dir__}/ca.crt",
                                  "--tls-auth-clients", "no")

    @process.io.stdout = @process.io.stderr = File.open('redis.log', 'w+')
  end

  def start
    process.start
  rescue ChildProcess::Error
    fail "redis-server could not start. Do you have it installed and on your PATH?"
    exit 1
  end

  def stop
    process.stop if process.alive?
  end

  private

  attr_reader :process
end
