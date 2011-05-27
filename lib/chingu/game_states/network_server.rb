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
    # A game state that acts server in a multiplayer game, suitable for smaller/middle sized games.
    # Used in combination with game state NetworkClient.
    #
    # Uses nonblocking polling TCP and YAML to communicate. 
    # If your game state inherits from NetworkClient you'll have the following methods available:
    #
    #   start(ip, port)                         # Start server listening on ip:port
    #   send_data(socket, data)                 # Send raw data on the network, nonblocking
    #   send_msg(socket, whatever ruby data)    # Will get YAML'd and sent to server
    #   broadcast_msg(whatever ruby data)       # Send stuff to all connected clients, buffered and dispatched each gametick
    #   handle_incoming_connections             # Nonblocking accept of incoming connections from clients
    #   handle_incoming_data(max_size)          # Nonblocking read of incoming server data

    #   
    # The following callbacks can be overwritten to add your game logic:
    #
    #   on_connect(socket)        # when the TCP connection to the server is opened
    #   on_disconnect(socket)     # when server dies or disconnects you
    #   on_data(socket, data)     # when raw data arrives from server, if not overloaded this will unpack and call on_msg
    #   on_msg(socket, msg)       # an incoming msgs, could be a ruby hash or array or whatever datastructure you've chosen to send from server
    #   on_start                  # called when socket is listening and ready
    #   on_start_error(msg)       # callback for any error during server setup process
    #
    # Usage:
    #   ServerState < Chingu::GameStates::NetworkServer
    #     # incoming client/connection...
    #     def on_connect(socket)
    #       send_msg(:cmd => :ping, :timestamp => Gosu::milliseconds)
    #     end
    #     
    #     def on_msg(socket, msg)
    #       if msg[:cmd] == :pong
    #         latency = Gosu::milliseconds - msg[:timestamp]
    #         puts "Server/Client roundtrip #{latency}ms"
    #       end
    #     end
    #   end
    #
    #   push_game_state ServerState.new(:ip => "127.0.0.1", :port => 7778).start
    #
    #  NetworkServer works mostly like NetworkClient with a few differences
    #  - since a server handles many sockets (1 for each connected client) all callbacks first argument is 'socket'
    #  - same with outgoing packets, send_data and send_msgs first argument is socket.
    #
    # A good idea is to have a socket-ivar in your Player-model and a Player.find_by_socket(socket)
    #
    class NetworkServer < Chingu::GameState
      PACKET_HEADER_LENGTH = 4
      PACKET_HEADER_FORMAT = "N"
      DEFAULT_PORT = 7778

      class PacketBuffer
        def initialize
          @data = '' # Buffered data.
          @length = nil # Length of the next packet. nil if header not read yet.
        end

        # Add data string to the buffer.
        def buffer_data(data)
          @data << data
        end

        # Call after adding data with #buffer_data until there are no more packets left.
        def next_packet
          # Read the header to find out the length of the next packet.
          unless @length
            if @data.length >= PACKET_HEADER_LENGTH
              @length = @data[0...PACKET_HEADER_LENGTH].unpack(PACKET_HEADER_FORMAT)[0]
              @data[0...PACKET_HEADER_LENGTH] = ''
            end
          end

          # If there is enough data after the header for the full packet, return it.
          if @length and @length <= @data.length
            begin
              packet =  @data[0...@length]
              @data[0...@length] = ''
              @length = nil
              return packet
            rescue TypeError => ex
              puts "Bad data received:\n#{@data.inspect}"
              raise ex
            end
          else
            return nil
          end
        end
      end

      attr_reader :socket, :sockets, :ip, :port, :max_connections
      alias_method :address, :ip
      
      def initialize(options = {})
        super
        
        @ip = options[:ip] || "0.0.0.0"
        @port = options[:port] || DEFAULT_PORT
        @debug = options[:debug]
        @max_read_per_update = options[:max_read_per_update] || 20000
        @max_connections = options[:max_connections] || 256
        
        @socket = nil
        @sockets = []
        @packet_buffers = Hash.new
      end
      
      #
      # Start server
      #
      def start(ip=nil, port=nil)
        @ip = ip      if ip
        @port = port  if port
        begin
          @socket = TCPServer.new(@ip, @port)
          on_start
        rescue
          on_start_error($!)
        end
        
        return self
      end
      
      #
      # Callback for when Socket listens correctly on given host/port
      #
      def on_start
        puts "* Server listening on #{ip}:#{port}"          if @debug
      end
      
      #
      # Callback for when something goes wrong with startup (when making TCP socket listen to a port)
      #
      def on_start_error(msg)
        if @debug
          puts "Can't start server on #{ip}:#{port}:\n"
          puts msg
        end
      end
        
        
        
      #
      # Default network loop:
      # 1) Save incoming connections with #handle_incoming_connections
      # 2) read raw data from server with #handle_incoming_data
      # 3) #handle_incoming_data call #on_data(data)
      # 4) #on_data(data) will call #on_msgs(msg)
      # 5) send all buffered broadcast data in one fell swoop
      #
      def update
        if @socket && !@socket.closed?
          handle_incoming_connections
          handle_incoming_data
        end

        super
      end
      
      #
      # on_connect will be called when client successfully makes a connection to server
      #
      def on_connect(socket)
        puts "[Client Connected: #{socket}]"      if @debug
      end
      
      #
      # on_disconnect will be called when server disconnects client for whatever reason
      #
      def on_disconnect(socket)
        puts "[Client Disconnected: #{socket}]"   if @debug
      end

      def handle_incoming_connections
        begin
          while socket = @socket.accept_nonblock
            if @sockets.size < @max_connections
              @sockets << socket
              @packet_buffers[socket] = PacketBuffer.new
              on_connect(socket)
            else
              socket.close
            end
          end
        rescue IO::WaitReadable, Errno::EINTR
        end
      end

      #
      # Call this from your update() to read from socket.
      # handle_incoming_data will call on_data(raw_data) when stuff comes on on the socket.
      #
      def handle_incoming_data(max_size = @max_read_per_update)
        @sockets.each do |socket|
          if IO.select([socket], nil, nil, 0.0)
            begin
              packet, sender = socket.recvfrom(max_size)
              on_data(socket, packet)
            rescue Errno::ECONNABORTED, Errno::ECONNRESET, IOError
              @packet_buffers[socket] = nil

              on_disconnect(socket)
            end
          end
        end
      end
  
      #
      # on_data(data) will be called from handle_incoming_data() by default.
      #
      def on_data(socket, data)
        buffer = @packet_buffers[socket]

        buffer.buffer_data data

        while packet = buffer.next_packet
          on_msg(socket, Marshal.load(packet))
        end
      end
      
      #
      # Broadcast 'msg' to all connected clients
      # Output is buffered and dispatched once each server-loop
      #
      def broadcast_msg(msg)
        data = Marshal.dump(msg)
        @sockets.each {|s| send_data(s, data) }
      end
      
      #
      # Send 'msg' to 'socket'.
      # 'msg' must responds to #to_yaml
      #
      def send_msg(socket, msg)
        send_data(socket, Marshal.dump(msg))
      end
      
      #
      # Send raw 'data' to the 'socket'
      #
      def send_data(socket, data)
        begin
          socket.write([data.length].pack(PACKET_HEADER_FORMAT))
          socket.write(data)
        rescue Errno::ECONNABORTED, Errno::ECONNRESET, Errno::EPIPE, Errno::ENOTCONN
          on_disconnect(socket)
        end        
      end

      #
      # Shuts down all communication (closes socket) with a specific socket
      #
      def disconnect_client(socket)
        socket.close
        @sockets.delete socket
        @packet_buffers.delete socket
        on_disconnect(socket)
      rescue Errno::ENOTCONN
      end

      # Ensure that the buffer is cleared of data to write (call at the end of update or, at least after all sends).
      def flush
        @sockets.each do |socket| 
          begin
            socket.flush 
          rescue IOError
            disconnect_client(socket)
          end
        end
      end
      
      #
      # Stops server
      #
      def stop
        return unless @socket
        
        @sockets.each {|socket| disconnect_client(socket) }
          @sockets = []
          @socket.close
          @socket = nil
        rescue Errno::ENOTCONN
      end
      alias close stop

    end
  end
end
