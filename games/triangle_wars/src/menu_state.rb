class Menu < Chingu::GameState
  def initialize(options)
    super   
    Text.size = 60
    x = 220
    @menu_items = []
    @menu_items << Text.new(:text => "START GAME", :x => x, :y => 200, :id => :start)
    @menu_items << Text.new(:text => "HELP", :x => x, :y => 300, :id => :help)
    @menu_items << Text.new(:text => "QUIT", :x => x, :y => 400, :id => :quit)    
    
    @red = Color.new(200,255,255,255)
    @red2 = Color.new(255,255,0,0)
    @white = Color.new(255,255,255)
    
    @logo = GameObject.new(:x => $window.width/2, :y => 70, :image => "triangle_wars.png", :zorder => 10)
    @background = GameObject.new(:image => "hubble_deep_field.png", :zorder => 0, :x => $window.width/2, :y => $window.height/2)
    @background.color = Color.new(150,255,255,255)
    
    @zoom_seed = Math::PI
    @zoom_seed_x = 0
    @zoom_seed_y = Math::PI
    self.input = { :up => :up, :down => :down, :return => :chose, :space => :chose}
    
  end
  
  def setup
    @menu_index = 0
    #Gosu::Song.new($window, "media/triangle_wars_intro.ogg").play
    Song["triangle_wars_intro.ogg"].play(true)
  end  
  
  def up
    @menu_index -= 1 if @menu_index > 0
  end
  
  def down
    @menu_index += 1 if @menu_index < @menu_items.size-1
  end
  
  def update
    @background.angle += 0.05    
    @background.factor = 1.5 + Math::sin(@zoom_seed += 0.001)

    @menu_items.each_with_index do |menu_item, index|
      if @menu_index == index
        menu_item.color = ($window.ticks % 2 == 0) ? @red : @red2
      else
        menu_item.color = @white
      end
    end
    
    super # let chingu update all GameOjject based objects (Text is)
  end
  
  def finalize
    Song["triangle_wars_intro.ogg"].stop
  end
  
  def chose
    puts "chose!"
    case @menu_items[@menu_index].options[:id]
      when :start then  push_game_state(Level.new(:level => 1))
      when :help  then  push_game_state(Help)
      when :quit  then  close
    end
  end
end
