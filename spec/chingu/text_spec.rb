require 'spec_helper'

module Chingu

  describe Text do

    describe "should initialize properly" do

      before :each do
        @game_window = Chingu::Window.new
      end

      after :each do
        @game_window.close
      end


      it 'default text == -No text specified-' do
        new_text = Chingu::Text.new(nil)
        expect(new_text.text).to eq '-No text specified-'
      end

      it 'uses default font if none specified' do
        new_text = Chingu::Text.new('some text')
        expect(new_text.gosu_font.name).to eq Gosu::default_font_name
      end

      it 'default line spacing == 1' do
        new_text = Chingu::Text.new('some text')
        expect(new_text.line_spacing).to eq 1
      end

      it 'default alignment == left' do
        new_text = Chingu::Text.new('some text')
        expect(new_text.align).to eq :left
      end


    end


    describe 'should respond to' do

      before :each do
        @game_window = Chingu::Window.new
      end

      after :each do
        @game_window.close
      end


      methods_expected = [:gosu_font, :text, :height, :width,
                          :line_spacing, :align,
                          :max_width, :background,
      ]

      let(:new_text) {
        Chingu::Text.new('some text')
      }

      methods_expected.each do |method|

        it "#{method}" do
          expect(new_text).to respond_to method
        end
      end


    end


    describe 'if max_width is given, ....' do

      it ':max_width is given; line_spaing, align, max_width should be used'

    end
  end

end
