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
  # Online high score list, remotely synced to www.gamvercv.com's RESTful web api.
  #
  # - fetch high scores, add new ones
  # - Iterate through highscores with each and each_with_index
  #
  # Requires gems 'crack' and 'rest_client', included on initialize.
  #
  class OnlineHighScoreList    
    def initialize(options = {})
      @limit = options[:limit] || 100
      @sort_on = options[:sort_on] || :score
      @login = options[:login] || options[:user]
      @password = options[:password]
      @game_id = options[:game_id]

      require 'rest_client'
      require 'crack/xml'
      @high_scores_resource = RestClient::Resource.new("http://api.gamercv.com/games/#{@game_id}/high_scores", 
                                              :user => @login, :password => @password, :timeout => 20, :open_timeout => 5)
                                              
      @high_scores = Array.new  # Keeping a local copy in a ruby array
    end
    
    #
    # Create a new high score list and try to load content from :file-parameter
    # If no :file is given, HighScoreList tries to load from file "high_score_list.yml"
    #
    def self.load(options = {})
      high_score_list = OnlineHighScoreList.new(options)
      high_score_list.load
      return high_score_list     
    end
            
    #
    # POSTs a new high score to the remote web service
    #
    # 'data' is a hash of key/value-pairs that can contain
    # :name - player-name, could be "AAA" or "Aaron Avocado"
    # :score - the score 
    # :text - free text, up to 255 chars, 
    #
    # Returns the position the new score got in the high score list.
    # return 1 for number one spot. returns -1 if it didn't quallify as a high scores.
    #
    def add(data)
      raise "No :name value in high score!"   if data[:name].nil?
      raise "No :score value in high score!"  if data[:score].nil?
      begin
        @res = @high_scores_resource.post({:high_score => data})
        data = Crack::XML.parse(@res)
        add_to_list(force_symbol_hash(data["high_score"]))
      rescue RestClient::RequestFailed
        puts "RequestFailed: couldn't add high score"
      rescue RestClient::ResourceNotFound
        return -1
      rescue RestClient::Unauthorized
        puts "Unauthorized to add high score (check :login and :password arguments)"
      end
      return data["high_score"]["position"]
    end
    alias << add
    
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
    # Load data from remove web service.
    # Under the hood, this is accomplished through a simple REST-interface
    # The returned XML-data is converted into a simple Hash (@high_scores), which is also returned from this method.
    #
    def load
      raise "You need to specify a Game_id to load a remote high score list"    unless defined?(@game_id)
      raise "You need to specify a Login to load a remote high score list"      unless defined?(@login)
      raise "You need to specify a Password to load a remote high score list"   unless defined?(@password)
      
      @high_scores.clear
      begin
        res = @high_scores_resource.get
        data = Crack::XML.parse(res)
        if data["high_scores"]
          data["high_scores"].each do |high_score|
            @high_scores.push(force_symbol_hash(high_score))
          end
        end
      rescue RestClient::ResourceNotFound
        puts "Couldn't find Resource, did you specify a correct :game_id ?"
      end
      
      @high_scores = @high_scores[0..@limit-1] unless @high_scores.empty?
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
    
    private
    
    def add_to_list(data)
      @high_scores.push(data)
      @high_scores.sort! { |a, b| b[@sort_on] <=> a[@sort_on] }
      @high_scores = @high_scores[0..@limit-1]
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