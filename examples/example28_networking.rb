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
    #
    # Since we have 2 games states going we don't switch to them ( i.e. push_game_state @server )
    # Rather we just call #update manually so they can do their thing. 
    #
    # Server#update will poll incoming connections, handle sockets and read/parse incomong data.
    # Client#update will read/parse incoming data, send output.
    #
    @client.update  
    @server.update
  end
  
end

#
# Our Client. We inherit from Chingu::GameStates::NetworkClient
#
class Client < GameStates::NetworkClient
  def on_connect
    $window.caption = "[#{self.ip}] Connected! Sending a msg..."
    send_msg(:message => :woff, :to => :dawg)
    send_msg(:hi => :there)
  end
  
  #
  # Only 1 argument, the msg, since client only does 1 connecion (the one to the server)
  #
  def on_msg(msg)
    puts "Client Got: #{msg.inspect}"
  end
end

#
# Our Server. We inherit from Chingu::GameStates::NetworkServer
#
class Server < GameStates::NetworkServer
  #
  # Overload on_msg callback in server to make something happen
  # Servers #on_msg takes 2 arguments, since server can handle many clients
  #
  def on_connect(socket)
    send_msg(socket, {:hi => :there})
  end
  
  def on_msg(socket, msg)
    puts "Server Got: #{msg.inspect}"
    send_msg(socket, {:woff => :mjau, :numbers => [1,2,3]})
  end
end

Game.new.show