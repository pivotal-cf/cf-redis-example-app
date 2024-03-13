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

class SentinelTLS13
  attr_reader :host, :port, :master_name

  def initialize(options)
    @host = options.fetch(:host)
    @port = options.fetch(:port)
    @master_name = options.fetch(:master_name)
  end

  def get_redis_instance
    # no connection pooling for this example
    sock = TCPSocket.new(@host, @port)
    client = TTTLS13::Client.new(sock, @host)
    client.connect

    client.write("SENTINEL get-master-addr-by-name #{master_name}\n")
    resp = client.read
    client.close

    parse_sentinel_response(resp)
  end

  def parse_sentinel_response(response)
    lines = response.split("\r\n")
    elements = lines[0][1..-1].to_i
    data = []
    i = 1
    elements.times do
      length = lines[i].split("$")[1].to_i
      data << lines[i + 1][0...length]
      i += 2
    end
    data
  end
end
