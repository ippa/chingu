require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Demonstrating Chingus OnlineHighScoreList-class
# 
# Syncs against http://www.gamercv.com/games/1-test
#
class Game < Chingu::Window
  def initialize
    super(640,400)
    self.input = {:esc => :exit, :a => :add, :r => :add_random}
    self.caption = "OnlineHighScoreList example. Press 'A' to add a top-score, 'R' to add a random."
    
    @title = PulsatingText.create("class OnlineHighScoreList & www.gamvercv.com", :x => $window.width/2, :y => 50, :size => 30)
    
    #
    # Load a remote high score list
    #
    @high_score_list = OnlineHighScoreList.load(:game_id => 1, :login => "chingu", :password => "chingu", :limit => 10)

    create_text
  end  
  
  def add
    data = {:name => "NEW", :score => (@high_score_list[0][:score].to_i + 10), :text => "Hello from Chingus example16.rb"}
    position = @high_score_list.add(data)
    puts "Got position: #{position.to_s}"
    create_text
  end

  def add_random
    data = {:name => "RND", :score => @high_score_list[0][:score]-rand(100), :text => "Random from Chingus example16.rb"}
    position = @high_score_list.add(data)
    puts "Got position: #{position.to_s}"
    create_text
  end

  def create_text
    Text.destroy_if { |text| text.size == 20 }
    
    #
    # Iterate through all high scores and create the visual represenation of it
    #
    @high_score_list.each_with_index do |high_score, index|
      y = index * 25 + 100
      Text.create(high_score[:name], :x => 200, :y => y, :size => 20)
      Text.create(high_score[:score], :x => 400, :y => y, :size => 20)
    end
  end
end

#
# colorful pulsating text...
#
class PulsatingText < Text
  has_traits :timer, :effect
  @@red = Color.new(0xFFFF0000)
  @@green = Color.new(0xFF00FF00)
  @@blue = Color.new(0xFF0000FF)
  
  def initialize(text, options = {})
    super(text, options)
    
    options = text  if text.is_a? Hash
    @pulse = options[:pulse] || false
    self.rotation_center(:center_center)
    every(20) { create_pulse }   if @pulse == false
  end
  
  def create_pulse
    pulse = PulsatingText.create(@text, :x => @x, :y => @y, :height => @height, :pulse => true, :image => @image, :zorder => @zorder+1)
    colors = [@@red, @@green, @@blue]
    pulse.color = colors[rand(colors.size)].dup
    pulse.mode = :additive
    pulse.alpha -= 150
    pulse.scale_rate = 0.002
    pulse.fade_rate = -3 + rand(2)
    pulse.rotation_rate = rand(2)==0 ? 0.05 : -0.05
  end
    
  def update
    destroy if self.alpha == 0
  end
  
end

Game.new.show
