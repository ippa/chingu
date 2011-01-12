#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

module Chingu
  module GameStates  
    #
    # A game state for a client in a multiplayer game, suitable for smaller/middle sized games.
    # Used in combination with game state NetworkServer.
    #
    # Uses nonblocking polling TCP and YAML to communicate. 
    # If your game state inherits from NetworkClient you'll have the following methods available:
    #
    #   connect(ip, port)     # Start a blocking connection period, updates in $window.caption
    #   send_data(data)                 # Send raw data on the network, nonblocking
    #   send_msg(whatever ruby data)    # Will get YAML'd and sent to server
    #   handle_incoming_data(max_size)  # Nonblocking read of incoming server data
    #   disconnect_from_server          # Shuts down all network connections
    #   
    # The following callbacks can be overwritten to add your game logic:
    #   on_connect              # when the TCP connection to the server is opened
    #   on_disconnect           # when server dies or disconnects you
    #   on_data(data)           # when raw data arrives from server, if not overloaded this will unpack and call on_msg
    #   on_msg(msg)             # an incoming msgs, could be a ruby hash or array or whatever datastructure you've chosen to send from server
    #   on_timeout              # connection timed out
    #   on_connection_refused   # server isn't listening on that port
    #
    # Usage:
    #   PlayState < Chingu::GameStates::NetworkClient
    #     def initialize(options = {})
    #       super   # this is always needed!
    #       connect(options[:ip], options[:port])
    #     end
    #     
    #     def on_connect
    #       send_msg(:cmd => :hello)
    #     end
    #     
    #     def on_msg(msg)
    #       if msg[:cmd] == :ping
    #         send_msg(:cmd => :pong, :timestamp => msg[:timestamp])   # send back timestamp so server can calcuate lag
    #       end
    #     end
    #   end
    #
    #   push_game_state PlayState.new(:ip => "127.0.0.1", :port => 7778))
    #
    #
    # So why not EventMachine? No doubt in my mind that EventMachine is a hell of a library Chingu rolls its own for 2 reasons:
    #
    #   AFAIK EventMachine can be hard to intergrate with the classic game loop, event machine wants its own loop
    #   Rubys nonblocking sockets work, so why not keep it simple
    #
    #
    class NetworkClient < Chingu::GameState
      attr_reader :latency, :socket, :packet_counter, :packet_buffer, :ip, :port
      
      def initialize(options = {})
        super
        
        @debug = true
        @socket = nil
        @latency = 0
        @packet_counter = 0
        @packet_buffer = ""
        @timeout = options[:timeout] || 4
      end
      
      #
      # Default network loop:
      # 1) read raw data from server with #handle_incoming_data
      # 2) #handle_incoming_data call #on_data(data)
      # 3) #on_data(data) will call #on_msgs(msg)
      #
      def update
        super
        handle_incoming_data
      end
      
      #
      # Connect to a given ip:port (the server)
      # Will timeout afte 4 seconds
      #
      def connect(ip, port = 7778)
        return if @socket
        @ip = ip
        @port = port
    
        begin
          $window.caption = "Connecting to #{ip}:#{port} ... "
          status = Timeout::timeout(@timeout) do
            @socket = TCPSocket.new(ip, port)
            @socket.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,1)
            on_connect
          end
        rescue Errno::ECONNREFUSED
          on_connection_refused
        rescue Timeout
          on_timeout
        end
      end
      
      def on_connection_refused
        $window.caption = "Server: CONNECTION REFUSED"
        connect(@ip, @port)
      end
      
      def on_timeout
        $window.caption = "Server: CONNECTION TIMED OUT"
        connect(@ip, @port)
      end
      
      #
      # on_connect will be called when client successfully makes a connection to server
      #
      def on_connect
        puts "[Connected to Server #{@ip}:#{@port}]" if @debug
      end
      
      #
      # on_disconnect will be called when server disconnects client for whatever reason
      #
      def on_disconnect
        puts "[Disconnected from Server]"           if @debug
      end

      #
      # Call this from your update() to read from socket.
      # handle_incoming_data will call on_data(raw_data) when stuff comes on on the socket.
      #
      def handle_incoming_data(amount = 1000)
        return unless @socket
        
        if IO.select([@socket], nil, nil, 0.0)
          begin
            packet, sender = @socket.recvfrom(amount)
            on_data(packet)        
          rescue Errno::ECONNABORTED
            on_disconnect
          end
        end
      end
  
      #
      # on_data(data) will be called from handle_incoming_data() by default.
      #
      def on_data(data)
        begin
          msgs = data.split("--- ")          
          if msgs.size > 1
            @packet_buffer << msgs[0...-1].join("--- ")
            YAML::load_documents(@packet_buffer) { |msg| on_msg(msg)  if msg }
            @packet_buffer = msgs.last
          else
            @packet_buffer << msgs.join
          end
        rescue ArgumentError
          puts "Bad YAML recieved:\n#{data}"
        end
      end
      
      #
      # Send a msg to the server
      # Can be whatever ruby-structure that responds to #to_yaml
      #
      def send_msg(msg)
        # the "---" part is a little hack to make server understand the YAML is fully transmitted.
        data = msg.to_yaml + "--- \n"
        send_data(data)
      end

      #
      # Send whatever raw data to the server
      #
      def send_data(data)
        @socket.write(data)
        @socket.flush
      end

      #
      # Shuts down all communication (closes socket) with server
      #
      def disconnect_from_server
        @socket.close
      end

    end
  end
end
