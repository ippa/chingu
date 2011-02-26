require 'spec_helper'

def data_set
  {
    "a Hash" => [{ :foo => :bar }],
    "a String" => ["Woof!"],
    "an Array" => [[1, 2, 3]],
    "a stream of packets" => [{ :foo => :bar }, "Woof!", [1, 2, 3]],
    "huge packet" => [[:frogspawn] * 1000]
  }
end

module Chingu
  describe "Network" do
    
    describe Chingu::GameStates::NetworkServer do
      it "should open listening port on start()" do
        @server = described_class.new(:ip => "0.0.0.0", :port => 9999)
        @server.should_receive(:on_start)
        @server.start
        @server.stop
      end

      it "should call on_start_error() if failing" do
        @server = described_class.new(:ip => "1.2.3.999", :port => 12345678) # crazy ip:port
        @server.should_receive(:on_start_error)
        @server.start
        @server.stop
      end

      it "should call on_connect() and on_disconnect() when client connects" do
        @server = described_class.new(:ip => "0.0.0.0", :port => 9999)
        @client = Chingu::GameStates::NetworkClient.new(:ip => "127.0.0.1", :port => 9999)
        
        @server.should_receive(:on_start)
        @server.should_receive(:on_connect).with(an_instance_of(TCPSocket))
        @client.should_receive(:on_connect)
        @server.start
        @client.connect
        @server.update
        
        @client.stop
        @server.stop
      end

    end
    
    describe Chingu::GameStates::NetworkClient do
      it "should call on_connection_refused callback when connecting to closed port" do
        @client = described_class.new(:ip => "127.0.0.1", :port => 55421) # closed we assume
        @client.should_receive(:on_connection_refused)
        @client.connect
      end
    end
    
    describe "Network communication" do
      before :each do
        @server = Chingu::GameStates::NetworkServer.new(:port => 9999).start
        @client = Chingu::GameStates::NetworkClient.new(:ip => "127.0.0.1", :port => 9999).connect
        @client2 = Chingu::GameStates::NetworkClient.new(:ip => "127.0.0.1", :port => 9999).connect
      end
      
      after :each do
        @server.close
        @client.close
        @client2.close
      end

      describe "From client to server" do
        data_set.each do |name, data|
          it "should send/recv #{name}" do
            data.each {|packet| @server.should_receive(:on_msg).with(an_instance_of(TCPSocket), packet) }
            data.each {|packet| @client.send_msg(packet) }

            @server.update
          end
        end
      end

      describe "From server to a specific client" do
        data_set.each do |name, data|
          it "should send/recv #{name}" do
            data.each {|packet| @client.should_receive(:on_msg).with(packet) }
            @server.update # Accept the client before sending, so we know of its socket.
            data.each { |packet| @server.send_msg(@server.sockets[0], packet) }

            @client.update
          end
        end
      end

      describe "From server to all clients" do
        data_set.each do |name, data|
          it "should send/recv #{name}" do
            @server.update # Accept the clients, so know about their existence to broadcast.

            # Data should be cached.
            data.each {|packet| @server.broadcast_msg(packet) }

            data.each do |packet|
              @client.should_receive(:on_msg).with(packet)
              @client2.should_receive(:on_msg).with(packet)
            end

            @server.update # Push the cached messages.
            @client.update
            @client2.update
          end
        end
      end
    end
  end
end
