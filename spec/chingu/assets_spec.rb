require 'spec_helper'

module Chingu
  describe Chingu::NamedResource do  
    before :each do
      @game = Chingu::Window.new
      
      # Gosu uses the paths based on where rspec is, not where this file is, so we need to do it manually!
      Gosu::Image::autoload_dirs.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'images')
    end

    after :each do
      @game.close
    end
    
    describe "Image" do
      it "should have default autoload dirs" do
        Gosu::Image.autoload_dirs.should include(".")
        Gosu::Image.autoload_dirs.should include("#{@game.root}/media")
      end
      
      it "should autoload image in Image.autoload_dirs" do
        Gosu::Image["rect_20x20.png"].should be_kind_of Gosu::Image
      end
    
      it "should return the same cached Gosu::Image if requested twice" do
        Gosu::Image["rect_20x20.png"].should == Gosu::Image["rect_20x20.png"]
      end
      
      #it "should raise error if image is nonexistent" do
      #  Gosu::Image["nonexistent_image.png"].should raise_error RuntimeError
      #end
      
    end

    describe "Song" do
      it "should have default autoload dirs" do
        Gosu::Song.autoload_dirs.should include(".")
        Gosu::Song.autoload_dirs.should include("#{@game.root}/media")
      end
    end
    
    describe "Sample" do
      it "should have default autoload dirs" do
        Gosu::Sample.autoload_dirs.should include(".")
        Gosu::Sample.autoload_dirs.should include("#{@game.root}/media")
      end
    end
        
    describe "Font" do
      it "should have default autoload dirs" do
        Gosu::Font.autoload_dirs.should include(".")
        Gosu::Font.autoload_dirs.should include("#{@game.root}/media")
      end
    end
    
  end
end
