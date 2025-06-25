require 'tttls1.3'

class RedisTLS13
  attr_reader :host, :port, :password

  def initialize(options)
    @host = options.fetch(:host)
    @port = options.fetch(:port)
    @password = options.fetch(:password)
  end

  def get(key)
    # no connection pooling for this example
    sock = TCPSocket.new(@host, @port)
    client = TTTLS13::Client.new(sock, @host)
    client.connect

    client.write("AUTH #{password}\r\n")

    resp = client.read
    if resp.nil? || !resp.strip.casecmp('+OK').zero?
      raise "Invalid password"
    end

    client.write("GET #{key}\r\n")
    resp = client.read


    client.close
    parse_response(resp)
  end

  def parse_response(resp)
    if resp.strip.casecmp('$-1').zero?
      return nil
    end

    # e.g resp: $7"\r\n"a value"\r\n
    arr = resp.split("\r\n")
    arr[1]
  end
end
