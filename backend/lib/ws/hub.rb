# lib/ws/hub.rb
require "set"

class Hub
  def initialize
    @connections = Set.new
  end

  def add(connection)
    @connections.add(connection)
  end

  def remove(connection)
    @connections.delete(connection)
  end

  def broadcast(message)
    @connections.each do |c|
      begin
        c.write(message)
        c.flush
      rescue
        @connections.delete(c)
      end
    end
  end
end