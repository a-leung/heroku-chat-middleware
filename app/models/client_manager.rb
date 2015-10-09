class ClientManager
  CHANNEL        = "chat-demo"

  @clients ||= []

  redis_url = 'redis://localhost:6379'
  @redis ||= Redis.new url: redis_url

  def self.initialize
    Thread.new do
      redis_url = 'redis://localhost:6379'
      redis = Redis.new url: redis_url
      redis.subscribe(CHANNEL) do |on|
        on.message do |channel, msg|
          @clients.each { |ws| ws.send(msg) }
        end
      end
    end
  end

  def self.add(client)
    @clients.append(client)
  end

  def self.remove(client)
    @clients.delete(client)
  end

  def self.send_message(message)
    @redis.publish(CHANNEL, self.sanitize(message))
  end

  private
  def self.sanitize(message)
    json = JSON.parse(message)
    json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
    JSON.generate(json)
  end
end
