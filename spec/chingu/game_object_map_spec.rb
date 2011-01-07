require 'spec_helper'
include Chingu


# Creates 20x20 pixel sized objects 
class MyGameObject < Chingu::GameObject
  trait :bounding_box
  def setup
    @image = Gosu::Image["rect_20x20.png"]
    self.rotation_center = :top_left
  end  
end

# Creates 40x40 pixel sized objects 
class MyBigGameObject < Chingu::GameObject
  trait :bounding_box
  def setup
    @image = Gosu::Image["rect_20x20.png"]
    self.rotation_center = :top_left
    self.size = [40,40]
  end
end

module Chingu

  describe "GameObjectMap with grid [20,20]" do
    before :each do
      @game = Chingu::Window.new
      
      # Gosu uses the paths based on where rspec is, not where this file is, so we need to do it manually!
      Gosu::Image::autoload_dirs.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'images')
      
      MyGameObject.destroy_all
      MyBigGameObject.destroy_all
      @game_object = MyGameObject.create
      @big_game_object = MyBigGameObject.create
    end

    after :each do
      @game.close
    end
    
    context "setup of test should consist of" do
      it "should contain 1 MyGameObject" do
        MyGameObject.size.should == 1
      end
      it "should contain 1 MyBigGameObject" do
        MyBigGameObject.size.should == 1
      end
      
    end

    context "containing a game object size 20x20 postion 0,0" do
      before :each do
        @game_object_map = GameObjectMap.new(:game_objects => MyGameObject.all, :grid => [20,20])
      end
      
      it "should be found at 0,0" do
        @game_object_map.at(0,0).should == @game_object
      end

      it "should be found at 10,10" do
        @game_object_map.at(10,10).should == @game_object
      end

      it "should be found at 20,20" do
        @game_object_map.at(20,20).should == nil
      end
      
      it "should Not be found at 21,21" do
        @game_object_map.at(21,21).should == nil
      end
    end

    context "containing a game object size 40x40 postion 0,0" do
      before :each do
        @game_object_map = GameObjectMap.new(:game_objects => MyBigGameObject.all, :grid => [20,20])
      end
      
      it "should be found at 0,0" do
        @game_object_map.at(0,0).should == @big_game_object
      end
      it "should be found at 20,20" do
        @game_object_map.at(20,20).should == @big_game_object
      end
      it "should be found at 39,39" do
        @game_object_map.at(39,39).should == @big_game_object
      end

      it "should Not be found at 40,40" do
        @game_object_map.at(40,40).should == nil
      end

    end
  end
end