require 'spec_helper'

def data_set
  {
    "a Hash" => [{ :foo => :bar }],
    "a String" => ["Woof!"],
    "an Array" => [[1, 2, 3]],
    "a stream of packets" => [{ :foo => :bar }, "Woof!", [1, 2, 3]],
    "huge packet" => [[:frogspawn] * 1000],
    "100 small packets" => 100.times.map { rand(100000) },
  }
end

module Chingu

  describe "Network" do
    
    describe Chingu::GameStates::NetworkServer do

      it "should open listening port on start()" do
        @server = described_class.new(:address => "0.0.0.0", :port => 9999)
        @server.should_receive(:on_start)
        @server.start
        @server.stop
      end

      it "client should timeout when connecting to blackhole ip" do
        @client = Chingu::GameStates::NetworkClient.new(:address => "1.2.3.4", :port => 1234, :debug => true)
        @client.connect
        
        @client.should_receive(:on_timeout)
        @client.update while @client.socket
      end

      it "should call on_start_error() if failing" do
        @server = described_class.new(:address => "1.2.3.999", :port => 12345678) # crazy address:port
        @server.should_receive(:on_start_error)
        @server.start
        @server.stop
      end

      it "should call on_connect() and on_disconnect() when client connects" do
        @server = described_class.new(:address => "0.0.0.0", :port => 9999)
        @client = Chingu::GameStates::NetworkClient.new(:address => "127.0.0.1", :port => 9999)
        
        @server.should_receive(:on_start)
        @server.should_receive(:on_connect).with(an_instance_of(TCPSocket))
        @client.should_receive(:on_connect)
        @server.start
        @client.connect

        @client.update until @client.connected?
        @server.update
        
        @client.stop
        @server.stop
      end

    end
    
    describe Chingu::GameStates::NetworkClient do
      describe "connect" do
        it "should call on_connection_refused callback when connecting to closed port", skip: true do
          @client = described_class.new(:address => "127.0.0.1", :port => 55421) # closed we assume
          @client.should_receive(:on_connection_refused)
          @client.connect
          5.times { @client.update }
        end
 
        it "should not call on_timeout callback when unable to connect for less time than the timeout" do
          @client = described_class.new(:address => "127.0.0.1", :port => 55421, :timeout => 250) # closed we assume
          @client.connect
          @client.should_not_receive(:on_timeout)
          5.times { @client.update; sleep 0.01 }
        end
      
        it "should call on_timeout callback when unable to connect for longer than the timeout" do
          @client = described_class.new(:address => "127.0.0.1", :port => 55421, :timeout => 250) # closed we assume
          @client.connect
          @client.update
          sleep 0.3   
          @client.should_receive(:on_timeout)        
          5.times { @client.update }
        end
      end
    end
    
    describe "Connecting" do
      before :each do        
        @client = Chingu::GameStates::NetworkClient.new(:address => "127.0.0.1", :port => 9999)    
        @server = Chingu::GameStates::NetworkServer.new(:port => 9999)        
      end
      
      it "should connect to the server, when the server starts before it" do
        #@server.start
        #@client.connect
        #5.times { @client.update }
        #@client.should be_connected
      end
      
      it "should connect to the server, even when the server isn't initialy available", skip: true do
        @client.connect
        3.times { @client.update; sleep 0.2; @server.update; @client.flush }
        @server.start
        3.times { @client.update; sleep 0.2; @server.update; @client.flush }
        @client.should be_connected
      end
      
      after :each do 
        @client.close
        @server.close
      end
    end
    
    describe "Network communication" do
      before :each do
        @server = Chingu::GameStates::NetworkServer.new(:port => 9999).start
        @client = Chingu::GameStates::NetworkClient.new(:address => "127.0.0.1", :port => 9999).connect
        @client2 = Chingu::GameStates::NetworkClient.new(:address => "127.0.0.1", :port => 9999).connect
        @client.update until @client.connected?
        @client2.update until @client2.connected?
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

            5.times { @server.update }
          end
        end
      end

      describe "From server to a specific client" do
        data_set.each do |name, data|
          it "should send/recv #{name}" do
            data.each {|packet| @client.should_receive(:on_msg).with(packet) }
            @server.update # Accept the client before sending, so we know of its socket.
            data.each { |packet| @server.send_msg(@server.sockets[0], packet) }

            5.times { @client.update }
          end
        end
      end

      describe "From server to all clients" do
        data_set.each do |name, data|
          it "should send/recv #{name}" do
            @server.update # Accept the clients, so know about their existence to broadcast.

            data.each do |packet|
              @client.should_receive(:on_msg).with(packet)
              @client2.should_receive(:on_msg).with(packet)
            end

            data.each {|packet| @server.broadcast_msg(packet) }

            5.times do
              @client.update
              @client2.update
            end
          end
        end
      end

      describe "byte and packet counters" do
        before :each do
          @packet = "Hello! " * 10
          @packet_length = Marshal.dump(@packet).length
          @packet_length_with_header = @packet_length + 4
        end

        it "should be zeroed initially" do
          [@client, @client2, @server].each do |network|
            network.packets_sent.should be 0
            network.bytes_sent.should be 0
            network.packets_received.should be 0
            network.bytes_received.should be 0
          end
        end

        describe "client to server" do
          before :each do
            @client.send_msg(@packet)
            @server.update
          end

          describe "client" do
            it "should increment counters correctly when sending a message" do
              @client.packets_sent.should eq 1
              @client.bytes_sent.should eq @packet_length_with_header
            end
          end

          describe "server" do
            it "should increment counters correctly when receiving a message" do
              @server.packets_received.should eq 1
              @server.bytes_received.should eq @packet_length_with_header
            end
          end
        end

        describe "server to client"  do

          before :each do
            @server.update
            @server.send_msg(@server.sockets[0], @packet)
            @client.update
          end

          describe "server" do
            it "should increment sent counters" do
              @server.packets_sent.should eq 1
              @server.bytes_sent.should eq @packet_length_with_header
            end
          end

          describe "client" do

            it "should increment received counters" do

              @client.packets_received.should eq 1
              @client.bytes_received.should eq @packet_length_with_header
              @client2.packets_received.should eq 0
              @client2.bytes_received.should eq 0
            end
          end
        end

        describe "server to clients"  do
          before :each do
            @server.update
            @server.broadcast_msg(@packet)
            @client.update
            @client2.update
          end

          describe "server" do
            it "should increment sent counters" do
              # Single message, broadcast to two clients.
              @server.packets_sent.should eq 2
              @server.bytes_sent.should eq @packet_length_with_header * 2
            end
          end

          describe "clients" do
            it "should increment received counters" do
              [@client, @client2].each do |client|
                client.packets_received.should eq 1
                client.bytes_received.should eq @packet_length_with_header
              end
            end
          end
        end
      end
    end
  end
end
