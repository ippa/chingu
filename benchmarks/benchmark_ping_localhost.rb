#!/usr/bin/env ruby
require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Simple
#
class Game < Chingu::Window
  
  def setup
    on_input(:esc, :exit)
    
    @client = Client.new
    @server = Server.new
    
    @server.start("0.0.0.0", 1234)
    @client.connect("127.0.0.1", 1234)
  end
  
  def update
    @client.update
    @client.update_trait
    @server.update
    @server.update_trait
  end
  
end

#
# Our Client. We inherit from Chingu::GameStates::NetworkClient
#
class Client < GameStates::NetworkClient
  trait :timer
  
  def on_connect
    $window.caption = "[CONNECTED]"
    send_msg(:timestamp => Gosu::milliseconds)
    every(1000) { send_msg(:timestamp => Gosu::milliseconds) }
  end
  
  def on_msg(msg)
    latency = (Gosu::milliseconds - msg[:timestamp])
    #puts "PONG: #{latency}ms"
    $window.caption = "PONG: #{latency}ms"
  end
  
end

#
# Our Server. We inherit from Chingu::GameStates::NetworkServer
#
class Server < GameStates::NetworkServer
  
  def on_msg(socket, msg)
    #puts "PING: #{msg[:timestamp]}"
    send_msg(socket, {:timestamp => msg[:timestamp]})
  end
  
end

Game.new.show