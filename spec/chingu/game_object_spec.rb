require 'spec_helper'

module Chingu

  describe GameObject do
    before :all do
      @game = Chingu::Window.new
      
      # Gosu uses the paths based on where rspec is, not where this file is, so we need to do it manually!
      Gosu::Image::autoload_dirs.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'images')
    end

    it { should respond_to(:x) }
    it { should respond_to(:y) }
    it { should respond_to(:angle) }
    it { should respond_to(:center_x) }
    it { should respond_to(:center_y) }
    it { should respond_to(:factor_x) }
    it { should respond_to(:factor_y) }
    it { should respond_to(:zorder) }
    it { should respond_to(:mode) }
    it { should respond_to(:color) }
    it { should respond_to(:attributes) }
    it { should respond_to(:draw) }
    it { should respond_to(:draw_at) }
    it { should respond_to(:draw_relative) }

    context "when created with defaults" do
      it "should have default values" do
        subject.angle.should == 0
        subject.x.should == 0
        subject.y.should == 0
        subject.factor_x.should == 1
        subject.factor_y.should == 1
        subject.center_x.should == 0.5
        subject.center_y.should == 0.5
        subject.mode.should == :default
        subject.image.should == nil        
        subject.color.to_s.should == Gosu::Color::WHITE.to_s
        subject.alpha.should == 255
      end
      
      it "should wrap angle at 360" do
        subject.angle.should == 0
        subject.angle += 30
        subject.angle.should == 30
        subject.angle += 360
        subject.angle.should == 30
      end

      it "shouldn't allow alpha below 0" do
        subject.alpha = -10
        subject.alpha.should == 0
      end

      it "shouldn't allow alpha above 255" do
        subject.alpha = 1000
        subject.alpha.should == 255
      end
    end
    
    it "should have the same value for self.alpha as self.color.alpha" do
      subject.alpha.should == subject.color.alpha
    end
    
    it "should have a corrent filename created from class name" do
      subject.filename.should == "game_object"
    end

    it "should raise an exception if the image fails to load" do
      lambda { described_class.new(:image => "monkey_with_a_nuclear_tail.png") }.should raise_error Exception
    end
    
    context "position" do
      it "inside_window?" do
        subject.x = 1
        subject.y = 1
        subject.inside_window?.should == true
        subject.outside_window?.should == false
      end
      it "outside_window?" do
        subject.x = @game.width + 1
        subject.y = @game.height + 1
        subject.inside_window?.should == false
        subject.outside_window?.should == true
      end
    end
    
    context "visibility" do
      it "should hide/show object on self.hide! and self.show!" do
        subject.hide!
        subject.visible?.should == false
        subject.show!
        subject.visible?.should == true
      end
    end

    context "when created with an image named in a string" do
      subject { described_class.new(:image => "rect_20x20.png") }

      it "should have width,height & size" do
        subject.height.should == 20
        subject.width.should == 20
        subject.size.should == [20,20]
      end
      
      it "should adapt width,height & size to scaling" do
        subject.factor = 2
        subject.height.should == 40
        subject.width.should == 40
        subject.size.should == [40,40]
      end

      it "should adapt factor_x/factor_y to new size" do
        subject.size = [10,40]  # half the width, double the height
        subject.width.should == 10
        subject.height.should == 40
        subject.factor_x.should == 0.5
        subject.factor_y.should == 2
      end
      
    end

    after(:all) do
      $window.close
    end
    
  end

end