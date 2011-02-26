require 'spec_helper'

module Chingu
  describe "Network" do
    
    describe "Network Server" do

      it "should open listening port on start()" do
        @server = Chingu::GameStates::NetworkServer.new(:ip => "0.0.0.0", :port => 9999)
        @server.should_receive(:on_start)
        @server.start
        @server.stop
      end

      it "should call on_start_error() if failing" do
        @server = Chingu::GameStates::NetworkServer.new(:ip => "1.2.3.999", :port => 12345678) # crazy ip:port
        @server.should_receive(:on_start_error)
        @server.start
        @server.stop
      end

      it "should call on_connect() and on_disconnect() when client connects" do
        @server = Chingu::GameStates::NetworkServer.new(:ip => "0.0.0.0", :port => 9999)
        @client = Chingu::GameStates::NetworkClient.new(:ip => "127.0.0.1", :port => 9999)
        
        @server.should_receive(:on_start)
        @server.should_receive(:on_connect).with(anything())  # anything() == a socket
        @client.should_receive(:on_connect)
        @server.start
        @client.connect
        @server.update
        
        @client.stop
        @server.stop
      end

    end
    
    describe "Network Client" do
      it "should call on_connection_refused callback when connecting to closed port" do
        @client = Chingu::GameStates::NetworkClient.new(:ip => "127.0.0.1", :port => 55421) # closed we assume
        @client.should_receive(:on_connection_refused)
        @client.connect
      end
    end
    
    describe "Network communication" do
      before do
        @server = Chingu::GameStates::NetworkServer.new(:ip => "0.0.0.0", :port => 9999).start
        @client = Chingu::GameStates::NetworkClient.new(:ip => "127.0.0.1", :port => 9999).connect
      end
      
      after do
        @server.close
        @client.close
      end
      
      it "should send/recv strings" do
        @server.should_receive(:on_msg).with(anything(), "woff!")
        @client.send_msg("woff!")
        @server.update
      end
      
      it "should send/recv hashes" do
        @server.should_receive(:on_msg).with(anything(), {:foo => :bar})
        @client.send_msg({:foo => :bar})
        @server.update
      end

      it "should send/recv arrays" do
        @server.should_receive(:on_msg).with(anything(), [1,2,3])
        @client.send_msg([1,2,3])
        @server.update
      end

    end
  end
end
