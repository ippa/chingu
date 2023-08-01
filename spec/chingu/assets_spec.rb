# frozen_string_literal: true

require 'spec_helper'

module Chingu
  describe Chingu::NamedResource do
    before :each do
      @game = Chingu::Window.new

      # Gosu uses the paths based on where rspec is, not where this file is, so we need to do it manually!
      Gosu::Image.autoload_dirs.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'images')
    end

    after :each do
      @game.close
    end

    describe 'Image' do
      it 'should have default autoload dirs' do
        expect(Gosu::Image.autoload_dirs).to include('.')
        expect(Gosu::Image.autoload_dirs).to include("#{@game.root}/media")
      end

      it 'should autoload image in Image.autoload_dirs' do
        expect(Gosu::Image['rect_20x20.png']).to be_kind_of(Gosu::Image)
      end

      it 'should return the same cached Gosu::Image if requested twice' do
        expect(Gosu::Image['rect_20x20.png']).to eq(Gosu::Image['rect_20x20.png'])
      end

      # it "should raise error if image is nonexistent" do
      #  Gosu::Image["nonexistent_image.png"].should raise_error RuntimeError
      # end
    end

    describe 'Song' do
      it 'should have default autoload dirs' do
        expect(Gosu::Song.autoload_dirs).to include('.')
        expect(Gosu::Song.autoload_dirs).to include("#{@game.root}/media")
      end
    end

    describe 'Sample' do
      it 'should have default autoload dirs' do
        expect(Gosu::Sample.autoload_dirs).to include('.')
        expect(Gosu::Sample.autoload_dirs).to include("#{@game.root}/media")
      end
    end

    describe 'Font' do
      it 'should have default autoload dirs' do
        expect(Gosu::Font.autoload_dirs).to include('.')
        expect(Gosu::Font.autoload_dirs).to include("#{@game.root}/media")
      end
    end
  end
end
