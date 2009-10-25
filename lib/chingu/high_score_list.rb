#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

module Chingu
  #
  # Highscore-class
  #
  # - Keeps a local YAML file with highscores, default highscores.yml in root game dir.
  # - Add, delete, clear highscores
  # - Iterate through highscores with simple HighScores#each
  #
  # Working with the high score list:
  # ...as a local file requires gem 'yaml'
  # ...as a remote gamercv.com resource requires gem 'crack' and 'rest_client'
  #
  class HighScoreList
    attr_reader :file
    
    #
    # Create a new high score list with 0 entries
    #
    def initialize(options = {})
      @file = options[:file] || "high_score_list.yml"
      @size = options[:size] || 100
      @sort_on = options[:sort_on] || :score
      
      @user = options[:user]
      @password = options[:password]
      @game_id = options[:game_id]
      @server = "http://api.gamercv.com"
      @resource = nil
      
      @high_scores = Array.new
    end
    
    #
    # Create a new high score list and try to load content from :file-parameter
    # If no :file is given, HighScoreList tries to load from file "high_score_list.yml"
    #
    def self.load(options = {})
      require 'yaml'
      high_score_list = HighScoreList.new(options)
      high_score_list.load
      return high_score_list
    end
    
    def self.load_remote(options = {})
      high_score_list = HighScoreList.new(options)
      high_score_list.load_remote
      return high_score_list      
    end
        
    #
    # Adda a new high score to the local file
    # 'data' is a hash of key/value-pairs that needs to contain at least the keys :name and :score
    # Returns the position it got in the list, with 1 beeing the first positions
    #
    def add(data)
      raise "No :name value in high score!"   if data[:name].nil?
      raise "No :score value in high score!"  if data[:score].nil?
      @resource ? add_remote(data) : add_local(data)
      position_by_score(data[:score])
    end
    alias << add
    
    #
    # POSTs a new high score to the remote web service
    #
    def add_remote(data)
      begin
        @res = @resource.post({:high_score => data})
        data = Crack::XML.parse(@res)
        add_to_list(force_symbol_hash(data["high_score"]))
      rescue RestClient::RequestFailed
        puts "RequestFailed: couldn't add high score"
      rescue RestClient::Unauthorized
        puts "Unauthorized to add high score (check :user and :password arguments)"
      end
    end
      
    #
    # Adds a new high score to local file
    # Returns the position it got in the list, with 1 beeing the first positions
    #
    def add_local(data)
      add_to_list(force_symbol_hash(data))
      save_to_file
    end

    #
    # Returns the position of full data-hash data entry, used internally
    #
    def position_by_data(data)
      position = @high_scores.rindex(data)
      position += 1 if position
    end
          
    #
    # Returns the position 'score' would get in among the high scores:
    #   @high_score_list.position_by_score(999999999) # most likely returns 1 for the number one spot
    #   @high_score_list.position_by_score(1)         # most likely returns nil since no placement is found (didn't make it to the high scores)
    #
    def position_by_score(score)
      position = 1
      @high_scores.each do |high_score|
        return position   if score > high_score[:score]
        position += 1
      end
      return nil
    end
    
    #
    # Load data from previously specified @file
    #
    def load
      @high_scores = YAML.load_file(@file)  if File.exists?(@file)
      @high_scores = @high_scores[0..@size]
    end

    #
    # Load data from remove web service.
    # Under the hood, this is accomplished through a simple REST-interface
    # The returned XML-data is converted into a simple Hash (@high_scores), which is also returned from this method.
    #
    def load_remote
      raise "You need to specify a Game_id to load a remote high score list"    unless defined?(@game_id)
      raise "You need to specify a User to load a remote high score list"       unless defined?(@user)
      raise "You need to specify a Password to load a remote high score list"   unless defined?(@password)
      
      require 'rest_client'
      require 'crack/xml'
      @resource = RestClient::Resource.new "#{@server}/games/#{@game_id}/high_scores", :user => @user, :password => @password, :timeout => 20, :open_timeout => 5
      
      @high_scores.clear
      begin
        res = @resource.get
        data = Crack::XML.parse(res)
        if data["high_scores"]
          data["high_scores"].each do |high_score|
            @high_scores.push(force_symbol_hash(high_score))
          end
        end
      rescue RestClient::ResourceNotFound
        puts "Couldn't find Resource, did you specify a correct :game_id ?"
      end
      
      @high_scores = @high_scores[0..@size]
      return @high_scores
    end
    
    #
    # Direct access to invidual high scores
    #
    def [](index)
      @high_scores[index]
    end
    
    #
    # Iterate through all high scores
    #
    def each
      @high_scores.each { |high_score| yield high_score }
    end
    
    def each_with_index
      @high_scores.each_with_index { |high_score, index| yield high_score, index }
    end

    #
    # Save high score data into previously specified @file
    #
    def save_to_file
      require 'yaml'
      File.open(@file, 'w') do |out|
        YAML.dump(@high_scores, out)
      end
    end

    private
    
    def add_to_list(data)
      @high_scores.push(data)
      @high_scores.sort! { |a, b| b[@sort_on] <=> a[@sort_on] }
      @high_scores = @high_scores[0..@size]
    end
    
    def force_symbol_hash(hash)
      symbol_hash = {}
      hash.each_pair do |key, value|
        symbol_hash[key.to_sym] = value
      end
      return symbol_hash
    end
        
  end
end