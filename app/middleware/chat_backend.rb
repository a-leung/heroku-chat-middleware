class ChatBackend
  KEEPALIVE_TIME = 15 # in seconds

  def initialize(app)
    @app     = app
  end

  def call(env)
    puts 'call'
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })


      ws.on :open do |event|
        p [:open, ws.object_id]
        ClientManager.add(ws)
      end

      ws.on :message do |event|
        p [:message, event.data]
        ClientManager.send_message(event.data)
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        ClientManager.remove(ws)
        ws = nil
      end

      # Return async Rack response
      ws.rack_response

    else
      @app.call(env)
    end
  end
end
