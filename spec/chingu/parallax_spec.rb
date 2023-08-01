# frozen_string_literal: true

require 'spec_helper'

module Chingu
  describe Parallax do
    before :each do
      @game = Chingu::Window.new

      # Gosu uses the paths based on where rspec is, not where this file is, so we need to do it manually!
      Gosu::Image.autoload_dirs.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'images')
    end

    after :each do
      @game.close
    end

    describe 'layers' do
      it 'should have 3 different ways of adding layers' do
        subject << { image: 'rect_20x20.png', repeat_x: true, repeat_y: true }
        subject.add_layer(image: 'rect_20x20.png', repeat_x: true, repeat_y: true)
        subject << ParallaxLayer.new(image: 'rect_20x20.png', repeat_x: true, repeat_y: true)

        subject.layers.count.should equal 3
      end

      it 'should have incrementing zorder' do
        3.times do
          subject.add_layer(image: 'rect_20x20.png')
        end
        subject.layers[1].zorder.should equal(subject.layers[0].zorder + 1)
        subject.layers[2].zorder.should equal(subject.layers[0].zorder + 2)
      end

      it 'should start incrementing zorder in layers from Parallax-instance zorder if available' do
        parallax = Parallax.new(zorder: 2000)
        3.times { parallax.add_layer(image: 'rect_20x20.png') }
        parallax.layers[0].zorder.should
        parallax.layers[1].zorder.should
        parallax.layers[2].zorder.should == 2002
      end
    end
  end
end
