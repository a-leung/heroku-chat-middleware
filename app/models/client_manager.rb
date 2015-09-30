class ClientManager
  CHANNEL        = "chat-demo"

  @clients ||= []

  uri = URI.parse('redis://localhost:6379')
  @redis ||= Redis.new(host: uri.host, port: uri.port, password: uri.password)

  def self.initialize

    Thread.new do
      @redis.subscribe(CHANNEL) do |on|
        on.message do |channel, msg|
          @clients.each { |ws| ws.send(msg) }
        end
      end
    end

  end

  def self.add(client)
    @clients << client
  end

  def self.remove(client)
    @clients.delete(client)
  end

  def self.send_message(message)
    @redis.publish(CHANNEL, sanitize(message))
  end

  private
  def sanitize(message)
    json = JSON.parse(message)
    json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
    JSON.generate(json)
  end

end
