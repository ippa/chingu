module Chingu
  module GameStates
    # Abstract state, parent of NetworkClient and NetworkServer.
    class NetworkState < GameState
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

      attr_reader :address, :port
      attr_reader :bytes_sent, :bytes_received
      attr_reader :packets_sent, :packets_received

      def initialize(options = {})
        raise "Can't instantiate abstract class" if self.class == NetworkState

        super(options)

        reset_counters

        @address = options[:address] || "0.0.0.0"
        @port = options[:port] || DEFAULT_PORT
        @debug = options[:debug]
      end

      # Resets #bytes_sent, #bytes_received, #packets_sent and #packets_received to zero.
      def reset_counters
        @bytes_sent = @bytes_received = 0
        @packets_sent = @packets_received = 0
        0
      end
    end
  end
end