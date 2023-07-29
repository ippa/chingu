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
    # Uses non-blocking polling TCP and marshal to communicate.
    # If your game state inherits from NetworkClient you'll have the following methods available:
    #
    #   connect(address, port)          # Start a non-blocking connection. only connect() uses previosly given ip:port
    #   send_data(data)                 # Send raw data on the network, non-blocking
    #   send_msg(whatever ruby data)    # Will get marshalled and sent to server
    #   handle_incoming_data(max_size)  # Non-blocking read of incoming server data
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
    #       connect(options[:address], options[:port])
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
    # So why not EventMachine? No doubt in my mind that EventMachine is a hell of a library, Chingu rolls its own for 2 reasons:
    #
    #   AFAIK EventMachine can be hard to integrate with the classic game loop, event machine wants its own loop
    #   Rubys non-blocking sockets work, so why not keep it simple
    #
    #
    class NetworkClient < NetworkState
      attr_reader :socket, :timeout

      def connected?; @connected; end
      
      def initialize(options = {})
        super(options)

        @timeout = options[:timeout] || 4000

        @max_read_per_update = options[:max_read_per_update] || 50000
        
        @socket = nil
        @connected = false
        @packet_buffer = PacketBuffer.new
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
          if Gosu::milliseconds >= @connect_times_out_at
            @socket = nil
            on_timeout
          else
            begin
              # Start/Check on our nonblocking tcp connection
              @socket.connect_nonblock(@sockaddr)
            rescue Errno::EINPROGRESS   #rescue IO::WaitWritable
            rescue Errno::EALREADY
            rescue Errno::EISCONN
              @connected = true
              on_connect
            rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EINVAL
              @socket = nil
              on_connection_refused
            rescue Errno::ETIMEDOUT
              @socket = nil
              on_timeout
            end
          end
        end
        
        handle_incoming_data if @connected

        super
      end
      
      #
      # Connect to a given address:port (the server)
      # Connect is done in a non-blocking manner.
      # May pass :address and :port, which will overwrite any existing values.
      def connect(options = {})
        options = {
          :address => @address,
          :port => @port,
          :reconnect => false, # Doesn't reset the timeout timer; used internally.
        }.merge! options
        
        return if @socket
        
        @address = options[:address]
        @port = options[:port]
    
        # Set up our @socket, update() will handle the actual nonblocking connection
        @socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
        @sockaddr = Socket.sockaddr_in(@port, @address)

        @connect_times_out_at = Gosu::milliseconds + @timeout unless options[:reconnect]
        
        return self
      end
      
      #
      # Called when connect() fails with connection refused (closed port)
      #
      def on_connection_refused
        puts "[on_connection_refused() #{@address}:#{@port}]"  if @debug
        connect(:reconnect => true)
      end

      #
      # Called when connect() receives no initial answer from server
      #
      def on_timeout
        puts "[on_timeout() #{@address}:#{@port}]"  if @debug
      end
      
      #
      # on_connect will be called when client successfully makes a connection to server
      #
      def on_connect
        puts "[Connected to Server #{@address}:#{@port}]"  if @debug
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
        return unless @socket and connected?
        
        if IO.select([@socket], nil, nil, 0.0)
          begin
            packet, sender = @socket.recvfrom(amount)
            on_data(packet)        
          rescue Errno::ECONNABORTED, Errno::ECONNRESET
            disconnect_from_server
          end
        end
      end
  
      #
      # on_data(data) will be called from handle_incoming_data() by default.
      #
      def on_data(data)
        @packet_buffer.buffer_data data

        @bytes_received += data.length

        while packet = @packet_buffer.next_packet
          @packets_received += 1
          begin
            on_msg(Marshal.load(packet))
          rescue TypeError
            disconnect_from_server
            break
          end
        end
      end

      # Handler when message packets are received. Should be overriden in your code.
      def on_msg(packet)
        # should be overridden.
      end
      
      #
      # Send a msg to the server
      #
      def send_msg(msg)
        send_data(Marshal.dump(msg))
      end

      #
      # Send whatever raw data to the server
      # Returns amount of data sent, including header.
      def send_data(data)
        length = @socket.write([data.length].pack(NetworkServer::PACKET_HEADER_FORMAT))
        length += @socket.write(data)
        @packets_sent += 1
        @bytes_sent += length
        length
      rescue Errno::ECONNABORTED, Errno::ECONNRESET, Errno::EPIPE, Errno::ENOTCONN
        disconnect_from_server
        0
      end

      # Ensure that the buffer is cleared of data to write (call at the end of update or, at least after all sends).
      def flush
        @socket.flush if @socket
      rescue IOError
        disconnect_from_server
      end

      #
      # Shuts down all communication (closes socket) with server
      #
      def disconnect_from_server
        @socket.close if @socket and not @socket.closed?
      rescue Errno::ENOTCONN
      ensure
        @socket = nil
        was_connected = @connected
        @connected = false
        on_disconnect if was_connected
      end
      alias close disconnect_from_server
      alias stop disconnect_from_server

    end
  end
end
