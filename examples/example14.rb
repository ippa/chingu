require 'rubygems'
require File.join(File.dirname($0), "..", "lib", "chingu")
include Gosu
include Chingu

#
# Demonstrating Chingus HighScoreList-class
# I couldn't keep myself from spicying it up some though  :P
#
class Game < Chingu::Window
  def initialize
    super(640,400)
    self.input = {:esc => :exit, :space => :remote_high_score, :a => :add}
    self.caption = "Example of Chingus HighScore class. Press Space to go to fetch high scores remotely!"
    
    @title = PulsatingText.create("HIGH SCORES", :x => $window.width/2, :y => 50, :size => 70)
    
    #
    # Load a list from disk, defaults to "high_score_list.yml"
    # Argument :size forces list to this size
    #
    @high_score_list = HighScoreList.load(:size => 10)

    #
    # Add some new high scores to the list. :name and :score are required but you can put whatever.
    # They will mix with the old scores, automatic default sorting on :score
    #
    10.times do
      data = {:name => "NEW", :score => rand(10000)}
      
      position = @high_score_list.add(data)
      if position
        puts "#{data[:name]} - #{data[:score]} got position #{position}"
      else
        puts "#{data[:name]} - #{data[:score]} didn't make it"
      end
    end
    
    create_text
    
    # @high_score_list.save_to_file  # Uncomment to save list to disk
  end
  
  def remote_high_score
    game_objects.destroy_all
    
    @title = PulsatingText.create("REMOTE WEBSERVICE HIGH SCORES", :x => $window.width/2, :y => 50, :size => 30)
    
    #
    # :game_id is the unique ID the game has on www.gamercv.com
    # :user is the login for that specific game (set by owner)
    # :password is the password for that specific game (set by owner)
    #
    # To read a high score list only :game_id is required
    # To write to a high score list :user and :password is required as well
    #
    @high_score_list = HighScoreList.load_remote(:game_id => 1, :user => "chingu", :password => "chingu", :size => 10)
    create_text
  end
  
  def add
    data = {:name => "NEW", :score => 1600}
    position = @high_score_list.add(data)
    puts "Got position: #{position.to_s}"
    create_text
  end
  
  def create_text
    @score_texts ||= []
    @score_texts.each { |text| text.destroy }
    
    #
    # Iterate through all high scores and create the visual represenation of it
    #
    @high_score_list.each_with_index do |high_score, index|
      y = index * 25 + 100
      @score_texts << Text.create(high_score[:name], :x => 200, :y => y, :size => 20)
      @score_texts << Text.create(high_score[:score], :x => 400, :y => y, :size => 20)
    end
    
    5.times do
      score = rand(20000)
      puts "position for possible score #{score}: #{@high_score_list.position_by_score(score)}"
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
