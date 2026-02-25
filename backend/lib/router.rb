require "json"
require "async/websocket/adapters/rack"
require_relative "auth/password"
require_relative "auth/token"
require_relative "repos/users_repo"

class Router
  def initialize(hub:)
    @hub = hub
  end

  def call(env)
    method = env["REQUEST_METHOD"]
    path = env["PATH_INFO"]
    case [method, path]
    when ["GET", "/health"] then
      json(200, { ok: true })
    when ["POST", "/api/register"] then
      raw = env["rack.input"].read
      params = JSON.parse(raw)
      username = params["username"]
      password = params["password"]
      if Repos::UsersRepo.find_by_username(username) then 
        return json(409, { error: "username_taken"})
      end
      digest = Auth::Password.hash(password)
      user_id = Repos::UsersRepo.create(username: username, password_digest: digest)
      token = Auth::Token.issue(user_id.to_s)
      json(200, { token: token, user: {id: user_id, username: username}})
    when ["POST", "/api/login"] then
      raw = env["rack.input"].read
      params = JSON.parse(raw)
      username = params["username"]
      password = params["password"]
      user = Repos::UsersRepo.find_by_username(username)
      return json(401, { error: "invalid_credentials" }) unless user

      ok = Auth::Password.verify(password, user[:password_digest])
      return json(401, { error: "invalid_credentials" }) unless ok

      token = Auth::Token.issue(user[:id].to_s)
      json(200, { token: token, user: { id: user[:id], username: user[:username] } })
    when ["GET", "/api/me"] then
      auth = env["HTTP_AUTHORIZATION"]
      return json(401, { error: "unauthorized" }) unless auth
      return json(401, { error: "unauthorized" }) unless auth.start_with?("Bearer ")

      token = auth.split(" ", 2)[1]
      user_id = Auth::Token.verify(token)
      return json(401, { error: "unauthorized" }) unless user_id

      user = Repos::UsersRepo.find_by_id(user_id)
      return json(401, { error: "unauthorized" }) unless user
      json(200, { user: { id: user[:id], username: user[:username] } })
    when ["GET", "/ws"]
      Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
        @hub.add(connection)

        begin
          while message = connection.read
            @hub.broadcast(message)
          end
        ensure
          @hub.remove(connection)
        end
      end or json(400, { error: "not_websocket" })
    else
      json(404, { error: "not_found"})
    end
  end

  private

  def json(status, obj)
    [
      status,
      { "Content-Type" => "application/json"},
      [JSON.generate(obj)]
    ]
  end
end