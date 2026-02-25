require_relative "router"
require_relative "ws/hub"

class App
  def initialize
    @hub = Hub.new
    @router = Router.new(hub: @hub)
  end

  def call(env)
    @router.call(env)
  end
end
