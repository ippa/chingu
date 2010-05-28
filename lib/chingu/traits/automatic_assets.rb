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
  module Traits
    #
    # A chingu trait providing:
		# - automatic detection and loading of images, sounds, animations
		#
		# For example:
		# 	class FireBall; has_traits :automatic_assets; end;
		#
		# Will automatically load fire_ball.png into @image
		#
    module AutomaticAssets
      
      module ClassMethods
        def initialize_trait(options = {})
					trait_options[:automatic_assets] = {:directory => "media", :play => true, :delay => 100}.merge(options)
        end				
      end
			
      def setup_trait(options)
				#puts "AutomaticAssets#setup_trait"
			
        @automatic_assets_options = {:debug => false}.merge(options)
				
				#
				# Try loading animation
				#
				glob = "#{trait_options[:automatic_assets][:directory]}/#{self.asset_label}_*"
				puts "Animations? #{glob}" if trait_options[:automatic_assets][:debug]
				if tile_file = Dir[glob].first
					if tile_file =~ /[a-zA-Z\_+]_(\d+)x(\d+)/
						width = $1.to_i
						height = $2.to_i
					end
					puts "Loading animation: #{tile_file}, width: #{width}, height: #{height}" if trait_options[:automatic_assets][:debug]
					@animation = Chingu::Animation.new(:file => tile_file, :size => [width, height], :delay => trait_options[:automatic_assets][:delay])
					@image = @animation.next
				#
				# Try loading image
				#
				else
					@image_postfixes = ["bmp", "png"]
					@image_postfixes.each do |postfix|
						image_name = "#{self.asset_label}.#{postfix}"
						puts "Trying to load #{image_name}"	if trait_options[:automatic_assets][:debug]
						
						begin
							@image = Gosu::Image.new($window, File.join(trait_options[:automatic_assets][:directory], image_name) )
						rescue
							@image = Image[image_name] if Image[image_name]
						end
					end
				end
				
				puts "!!! automatic_assets couldn't find any image for class #{self.class}" unless @image
				
				super
      end
			
			def asset_label
				Chingu::Inflector.underscore(self.class.to_s)
			end
                  
      def update_trait
				if @animation	&& trait_options[:automatic_assets][:play]
					self.image = @animation.next	
				end
				
				super
      end
      
    end
  end
end