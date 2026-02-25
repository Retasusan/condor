require "jwt"

module Auth
  module Token
    JWT_SECRET = ENV.fetch("JWT_SECRET")

    module_function

    def issue(user_id)
      payload = {
        sub: user_id,
        iat: Time.now.to_i,
        exp: Time.now.to_i + 60*60*24*7
      }
      JWT.encode(payload, JWT_SECRET, "HS256")
    end

    def verify(token)
      payload, _header = JWT.decode(token, JWT_SECRET, true, algorithms: "HS256")
      payload["sub"]
    rescue
      nil
    end
  end
end
