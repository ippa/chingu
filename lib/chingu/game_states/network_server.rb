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
    # A game state that acts server in a multi-player game, suitable for smaller/middle sized games.
    # Used in combination with game state NetworkClient.
    #
    # Uses non-blocking polling TCP and marshal to communicate.
    # If your game state inherits from NetworkClient you'll have the following methods available:
    #
    #   start(address, port)                    # Start server listening on address:port
    #   send_data(socket, data)                 # Send raw data on the network, non-blocking
    #   send_msg(socket, whatever ruby data)    # Will get Marshalled and sent to server
    #   broadcast_msg(whatever ruby data)       # Send stuff to all connected clients, buffered and dispatched each gametick
    #   handle_incoming_connections             # Non-blocking accept of incoming connections from clients
    #   handle_incoming_data(max_size)          # Non-blocking read of incoming server data

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
    #   push_game_state NetworkServer.new(:address => "127.0.0.1", :port => 7778).start
    #
    #  NetworkServer works mostly like NetworkClient with a few differences
    #  - since a server handles many sockets (1 for each connected client) all callbacks first argument is 'socket'
    #  - same with outgoing packets, #send_data and #send_msg, first argument is a socket.
    #
    # A good idea is to have a socket-ivar in your Player-model and a Player.find_by_socket(socket)
    #
    class NetworkServer < NetworkState
      attr_reader :socket, :sockets, :max_connections
      
      def initialize(options = {})
        super(options)

        @max_read_per_update = options[:max_read_per_update] || 20000
        @max_connections = options[:max_connections] || 256

        @socket = nil
        @sockets = []
        @packet_buffers = Hash.new
      end

      #
      # Start server
      #
      def start(address = nil, port = nil)
        @address = address if address
        @port = port  if port
        begin
          @socket = TCPServer.new(@address, @port)
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
        puts "* Server listening on #{address}:#{port}"          if @debug
      end
      
      #
      # Callback for when something goes wrong with startup (when making TCP socket listen to a port)
      #
      def on_start_error(msg)
        if @debug
          puts "Can't start server on #{address}:#{port}:\n"
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
              socket.close # Just kick the client. We don't want them :)
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
              disconnect_client(socket)
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

        @bytes_received += data.length

        while packet = buffer.next_packet
          @packets_received += 1
          begin
            on_msg(socket, Marshal.load(packet))
          rescue TypeError
            disconnect_client(socket)
            break
          end
        end
      end

      # Handler when message packets are received. Should be overriden in your code.
      def on_msg(socket, packet)
        # should be overridden.
      end
      
      #
      # Broadcast 'msg' to all connected clients.
      # Returns amount of data sent.
      def broadcast_msg(msg)
        data = Marshal.dump(msg)
        @sockets.each {|s| send_data(s, data) }
        data.length * @sockets.size
      end

      #
      # Send 'msg' to a specific client 'socket'.
      # Returns amount of data sent.
      def send_msg(socket, msg)
        data = Marshal.dump(msg)
        send_data(socket, data)
        data.length
      end
      
      #
      # Send raw 'data' to the 'socket'
      # Returns amount of data sent, including headers.
      def send_data(socket, data)
        length = socket.write([data.length].pack(PACKET_HEADER_FORMAT))
        length += socket.write(data)
        @packets_sent += 1
        @bytes_sent += length
      rescue Errno::ECONNABORTED, Errno::ECONNRESET, Errno::EPIPE, Errno::ENOTCONN
        disconnect_client(socket)
      end

      #
      # Shuts down all communication (closes socket) with a specific socket
      #
      def disconnect_client(socket)
        socket.close and not @socket.closed?
      rescue Errno::ENOTCONN
      ensure
        @sockets.delete socket
        @packet_buffers.delete socket
        on_disconnect(socket)
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
        begin
          @socket.close if @socket and not @socket.closed?
        rescue Errno::ENOTCONN
        end

        @socket = nil
        @sockets.each {|socket| disconnect_client(socket) }
        @sockets = []
      end

      alias close stop

    end
  end
end
