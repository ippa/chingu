# frozen_string_literal: true

require 'spec_helper'

module Chingu
  describe Inflector do
    describe '.camelize' do
      it 'camelizes strings' do
        subject.camelize('automatic_assets').should eql('AutomaticAssets')
      end
    end

    describe '.underscore' do
      it 'converts class-like strings to underscore' do
        subject.underscore('FireBall').should eql('fire_ball')
      end
    end
  end
end
