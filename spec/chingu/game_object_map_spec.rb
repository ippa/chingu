require 'spec_helper'

module Chingu

  describe GameObjectMap do
    before :each do
      @game = Chingu::Window.new
      
      # Gosu uses the paths based on where rspec is, not where this file is, so we need to do it manually!
      Gosu::Image::autoload_dirs.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'images')
    end

    after :each do
      @game.close
    end

    it { should respond_to(:create_map) }
    it { should respond_to(:insert) }

    context "" do
      it "should " do
      end
    end
    
  end
end