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
    #   connect(ip, port)               # Start a nonblocking connection. only connect() uses previosly given ip:port
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
      alias_method :address, :ip

      def connected?; @connected; end
      
      def initialize(options = {})
        super
        @timeout = options[:timeout] || 4        
        @debug = options[:debug]
        @ip = options[:ip] || "0.0.0.0"
        @port = options[:port] || NetworkServer::DEFAULT_PORT
        @max_read_per_update = options[:max_read_per_update] || 50000
        
        @socket = nil
        @connected = false
        @latency = 0
        @packet_counter = 0
        @packet_buffer = NetworkServer::PacketBuffer.new
      end
      
      #
      # Default network loop:
      # 1) Try to complete outgoing connection if connect() has been called
      # 2) read raw data from server with #handle_incoming_data
      # 3) #handle_incoming_data call #on_data(data)
      # 4) #on_data(data) will call #on_msgs(msg)
      #
      def update
  
        if @socket and not @connected
          begin
            # Start/Check on our nonblocking tcp connection
            @socket.connect_nonblock(@sockaddr)
          rescue Errno::EINPROGRESS   #rescue IO::WaitWritable
          rescue Errno::EALREADY
            if IO.select([@socket],nil,nil,0.1).nil?
              @socket = nil
              on_connection_refused
            end
          rescue Errno::EISCONN
            @connected = true
            on_connect
          rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED, Errno::ECONNRESET
            on_connection_refused
          rescue Errno::ETIMEDOUT
            on_timeout
          end
        end
        
        handle_incoming_data
        super
      end
      
      #
      # Connect to a given ip:port (the server)
      # Connect is done in a blocking manner.      
      # Will timeout after 4 seconds
      #
      def connect(ip = nil, port = nil)
        return if @socket
        
        @ip = ip      if ip
        @port = port  if port
    
        # Set up our @socket, update() will handle the actual nonblocking connection
        @socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
        @sockaddr = Socket.sockaddr_in(@port, @ip)
        
        return self
      end
      
      #
      # Called when connect() fails with connection refused (closed port)
      #
      def on_connection_refused
        connect(@ip, @port)
      end

      #
      # Called when connect() recieves no initial answer from server
      #
      def on_timeout
        connect(@ip, @port)
      end
      
      #
      # on_connect will be called when client successfully makes a connection to server
      #
      def on_connect
        puts "[Connected to Server #{@ip}:#{@port}]"  if @debug
      end
      
      #
      # on_disconnect will be called when server disconnects client for whatever reason
      #
      def on_disconnect
        puts "[Disconnected from Server]"             if @debug
      end

      #
      # Call this from your update() to read from socket.
      # handle_incoming_data will call on_data(raw_data) when stuff comes on on the socket.
      #
      def handle_incoming_data(amount = @max_read_per_update)
        return unless @socket
        
        if IO.select([@socket], nil, nil, 0.0)
          begin
            packet, sender = @socket.recvfrom(amount)
            on_data(packet)        
          rescue Errno::ECONNABORTED, Errno::ECONNRESET
            @connected = false
            @socket = nil
            on_disconnect
          end
        end
      end
  
      #
      # on_data(data) will be called from handle_incoming_data() by default.
      #
      def on_data(data)
        @packet_buffer.buffer_data data

        while packet = @packet_buffer.next_packet
          on_msg(Marshal.load(packet))
        end
      end
      
      #
      # Send a msg to the server
      # Can be whatever ruby-structure that responds to #to_yaml
      #
      def send_msg(msg)
        send_data(Marshal.dump(msg))
      end

      #
      # Send whatever raw data to the server
      #
      def send_data(data)
        begin
          @socket.write([data.length].pack(NetworkServer::PACKET_HEADER_FORMAT))
          @socket.write(data)
        rescue Errno::ECONNABORTED, Errno::ECONNRESET, Errno::EPIPE, Errno::ENOTCONN
          @connected = false
          @socket = nil
          on_disconnect
        end
      end

      # Ensure that the buffer is cleared of data to write (call at the end of update or, at least after all sends).
      def flush
        @socket.flush
      end

      #
      # Shuts down all communication (closes socket) with server
      #
      def disconnect_from_server
        @socket.close
      end
      alias close disconnect_from_server
      alias stop disconnect_from_server

    end
  end
end
