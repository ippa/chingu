#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2007  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++

#--
# Table of Contents:
#
# class Rect
# 	GENERAL:
# 		initialize
# 		new_from_object
# 		to_s
# 		to_a, to_ary
# 		[]
# 	ATTRIBUTES:
# 		x, y, w, h [<- accessors]
# 		width, height, size
# 		left, top, right, bottom
# 		center, centerx, centery
# 		topleft, topright
# 		bottomleft, bottomright
# 		midleft, midtop, midright, midbottom
# 	UTILITY METHODS:
# 		clamp, clamp!
# 		clip, clip!
# 		collide_hash, collide_hash_all
# 		collide_array, collide_array_all
# 		collide_point?
# 		collide_rect?
# 		contain?
# 		inflate, inflate!
# 		move, move!
# 		normalize, normalize!
# 		union, union!
# 		union_all, union_all!
#
#	class Surface
#		make_rect
# 
#++

module Chingu

# A Rect is a representation of a rectangle, with four core attributes
# (x offset, y offset, width, and height) and a variety of functions
# for manipulating and accessing these attributes.
#
# Like all coordinates in Rubygame (and its base library, SDL), x and y
# offsets are measured from the top-left corner of the screen, with greater
# y offsets being lower. Thus, specifying the x and y offsets of the Rect
# is equivalent to setting the location of its top-left corner.
# 
# In Rubygame, Rects are used for collision detection and describing 
# the area of a Surface to operate on.
class Rect < Array

	#--
	# GENERAL
	#++

	# Create a new Rect, attempting to extract its own information from 
	# the given arguments. The arguments must fall into one of these cases:
	# 
	#   - 4 integers +(x, y, w, h)+.
	#   - 1 Rect or Array containing 4 integers +([x, y, w, h])+.
	#   - 2 Arrays containing 2 integers each +([x,y], [w,h])+.
	#   - 1 object with a +rect+ attribute which is a valid Rect object.
	# 
	# All rect core attributes (x,y,w,h) must be integers.
	# 
	def initialize(*argv)
		case argv.length
		when 1
			if argv[0].kind_of? Array; super(argv[0])
			elsif argv[0].respond_to? :rect; super(argv[0])
			end
		when 2
			super(argv[0].concat(argv[1]))
		when 4
			super(argv)
		end
		return self
	end

	# Extract or generate a Rect from the given object, if possible, using the
	# following process:
	# 
	#  1. If it's a Rect already, return a duplicate Rect.
	#  2. Elsif it's an Array with at least 4 values, make a Rect from it.
	#  3. Elsif it has a +rect+ attribute., perform (1) and (2) on that.
	#  4. Otherwise, raise TypeError.
	# 
	# See also Surface#make_rect()
	def Rect.new_from_object(object)
		case(object)
		when Rect
			return object.dup
		when Array 
			if object.length >= 4
				return Rect.new(object)
			else
				raise(ArgumentError,"Array does not have enough indices to be made into a Rect (%d for 4)."%object.length )
			end
		else
			begin
				case(object.rect)
				when Rect
					return object.rect.dup
				when Array
					if object.rect.length >= 4
						return Rect.new(object.rect)
					else
						raise(ArgumentError,"Array does not have enough indices to be made into a Rect (%d for 4)."%object.rect.length )
					end
				end				# case object.rect
			rescue NoMethodError # if no rect.rect
				raise(TypeError,"Object must be a Rect or Array [x,y,w,h], or have an attribute called 'rect'. (Got %s instance.)"%object.class)
			end
		end # case object
	end


	# Print the Rect in the form "+#<Rect [x,y,w,h]>+"
	def to_s; "#<Rect [%s,%s,%s,%s]>"%self; end

	# Print the Rect in the form "+#<Rect:id [x,y,w,h]>+"
	def inspect; "#<Rect:#{self.object_id} [%s,%s,%s,%s]>"%self; end

	#--
	# ATTRIBUTES
	#++

	# Returns self.at(0)
	def x; return self.at(0); end
	# Sets self[0] to +val+
	def x=(val); self[0] = val; end

	alias left x
	alias left= x=;
	alias l x
	alias l= x=;

	# Returns self.at(1)
	def y; return self.at(1); end
	# Sets self[1] to +val+
	def y=(val); self[1] = val; end

	alias top y
	alias top= y=;
	alias t y
	alias t= y=;

	# Returns self.at(2)
	def w; return self.at(2); end
	# Sets self[2] to +val+
	def w=(val); self[2] = val; end

	alias width w
	alias width= w=;

	# Returns self.at(3)
	def h; return self.at(3); end
	# Sets self[3] to +val+
	def h=(val); self[3] = val; end

	alias height h
	alias height= h=;

	# Return the width and height of the Rect.
	def size; return self[2,2]; end

	# Set the width and height of the Rect.
	def size=(size)
	 raise ArgumentError, "Rect#size= takes an Array of form [width, height]." if size.size != 2
	 self[2,2] = size
	 size
	end

	# Return the x coordinate of the right side of the Rect.
	def right; return self.at(0)+self.at(2); end

	# Set the x coordinate of the right side of the Rect by translating the
	# Rect (adjusting the x offset).
	def right=(r); self[0] = r - self.at(2); return r; end

	alias r right
	alias r= right=;

	# Return the y coordinate of the bottom side of the Rect.
	def bottom; return self.at(1)+self.at(3); end

	# Set the y coordinate of the bottom side of the Rect by translating the
	# Rect (adjusting the y offset).
	def bottom=(b); self[1] = b - self.at(3); return b; end

	alias b bottom
	alias b= bottom=;

	# Return the x and y coordinates of the center of the Rect.
	def center; return self.centerx, self.centery; end

	# Set the x and y coordinates of the center of the Rect by translating the
	# Rect (adjusting the x and y offsets).
	def center=(center)
	    raise ArgumentError, "Rect#center= takes an Array of the form [x,y]." if center.size != 2
		self.centerx, self.centery = center
		center
	end
	alias c center
	alias c= center=;

	# Return the x coordinate of the center of the Rect
	def centerx; return self.at(0)+(self.at(2).div(2)); end

	# Set the x coordinate of the center of the Rect by translating the
	# Rect (adjusting the x offset).
	def centerx=(x); self[0] = x - (self.at(2).div(2)); return x; end

	alias cx centerx
	alias cx= centerx=;

	# Return the y coordinate of the center of the Rect
	def centery; return self.at(1)+(self.at(3).div(2)); end

	# Set the y coordinate of the center of the Rect by translating the
	# Rect (adjusting the y offset).
	def centery=(y); self[1] = y- (self.at(3).div(2)); return y; end

	alias cy centery
	alias cy= centery=;

	# Return the x and y coordinates of the top-left corner of the Rect
	def topleft; return self[0,2].to_a; end

	# Set the x and y coordinates of the top-left corner of the Rect by 
	# translating the Rect (adjusting the x and y offsets).
	def topleft=(topleft)
	    raise ArgumentError, "Rect#topright= takes an Array of form [x, y]." if topleft.size != 2
		self[0,2] = topleft
		return topleft
	end

	alias tl topleft
	alias tl= topleft=;

	# Return the x and y coordinates of the top-right corner of the Rect
	def topright; return self.right, self.at(1); end

	# Set the x and y coordinates of the top-right corner of the Rect by 
	# translating the Rect (adjusting the x and y offsets).
	def topright=(topright)
	    raise ArgumentError, "Rect#topright= takes an Array of form [x, y]." if topright.size != 2
		self.right, self[1] = topright
		return topright
	end

	alias tr topright
	alias tr= topright=;

	# Return the x and y coordinates of the bottom-left corner of the Rect
	def bottomleft; return self.at(0), self.bottom; end

	# Set the x and y coordinates of the bottom-left corner of the Rect by 
	# translating the Rect (adjusting the x and y offsets).
	def bottomleft=(bottomleft)
		raise ArgumentError, "Rect#bottomleft= takes an Array of form [x, y]." if bottomleft.size != 2
		self[0], self.bottom = bottomleft
		return bottomleft
	end

	alias bl bottomleft
	alias bl= bottomleft=;

	# Return the x and y coordinates of the bottom-right corner of the Rect
	def bottomright; return self.right, self.bottom; end

	# Set the x and y coordinates of the bottom-right corner of the Rect by 
	# translating the Rect (adjusting the x and y offsets).
	def bottomright=(bottomright)
		raise ArgumentError, "Rect#bottomright= takes an Array of form [x, y]." if bottomright.size != 2
		self.right, self.bottom = bottomright
		return bottomright
	end

	alias br bottomright
	alias br= bottomright=;

	# Return the x and y coordinates of the midpoint on the left side of the
	# Rect.
	def midleft; return self.at(0), self.centery; end	

	# Set the x and y coordinates of the midpoint on the left side of the Rect
	# by translating the Rect (adjusting the x and y offsets).
	def midleft=(midleft)
    	raise ArgumentError, "Rect#midleft= takes an Array of form [x, y]." if midleft.size != 2
		self[0], self.centery = midleft
		return midleft
	end

	alias ml midleft
	alias ml= midleft=;

	# Return the x and y coordinates of the midpoint on the left side of the
	# Rect.
	def midtop; return self.centerx, self.at(1); end	

	# Set the x and y coordinates of the midpoint on the top side of the Rect
	# by translating the Rect (adjusting the x and y offsets).
	def midtop=(midtop)
    	raise ArgumentError, "Rect#midtop= takes an Array of form [x, y]." if midtop.size != 2
		self.centerx, self[1] = midtop
		return midtop
	end

	alias mt midtop
	alias mt= midtop=;

	# Return the x and y coordinates of the midpoint on the left side of the
	# Rect.
	def midright; return self.right, self.centery; end	

	# Set the x and y coordinates of the midpoint on the right side of the Rect
	# by translating the Rect (adjusting the x and y offsets).
	def midright=(midright)
    	raise ArgumentError, "Rect#midright= takes an Array of form [x, y]." if midright.size != 2
		self.right, self.centery = midright
		return midright
	end

	alias mr midright
	alias mr= midright=;

	# Return the x and y coordinates of the midpoint on the left side of the
	# Rect.
	def midbottom; return self.centerx, self.bottom; end	

	# Set the x and y coordinates of the midpoint on the bottom side of the
	# Rect by translating the Rect (adjusting the x and y offsets).
	def midbottom=(midbottom)
    	raise ArgumentError, "Rect#midbottom= takes an Array of form [x, y]." if midbottom.size != 2
		self.centerx, self.bottom = midbottom
		return midbottom
	end

	alias mb midbottom
	alias mb= midbottom=;

	#--
	# UTILITY METHODS
	#++


	# As #clamp!, but the original caller is not changed.
	def clamp(rect)
		self.dup.clamp!(rect)
	end

	# Translate the calling Rect to be entirely inside the given Rect. If 
	# the caller is too large along either axis to fit in the given rect,
	# it is centered with respect to the given rect, along that axis.
	def clamp!(rect)
		nself = self.normalize
		rect = Rect.new_from_object(rect)
		#If self is inside given, there is no need to move self
		unless rect.contain?(nself)

			#If self is too wide:
			if nself.at(2) >= rect.at(2)
				self[0] = rect.centerx - nself.at(2).div(2)
				#Else self is not too wide
			else
				#If self is to the left of arg
				if nself.at(0) < rect.at(0)
					self[0] = rect.at(0)
				#If self is to the right of arg
				elsif nself.right > rect.right
					self[0] = rect.right - nself.at(2)
				#Otherwise, leave x alone
				end
			end

			#If self is too tall:
			if nself.at(3) >= rect.at(3)
				self[1] = rect.centery - nself.at(3).div(2)
				#Else self is not too tall
			else
				#If self is above arg
				if nself.at(1) < rect.at(1)
					self[1] = rect.at(1)
				#If self below arg
				elsif nself.bottom > rect.bottom
					self[1] = rect.bottom - nself.at(3)
				#Otherwise, leave y alone
				end
			end
		end
		return self
	end

	# As #clip!, but the original caller is not changed.
	def clip(rect)
		self.dup.clip!(rect)
	end

	# Crop the calling Rect to be entirely inside the given Rect. If the
	# caller does not intersect the given Rect at all, its width and height
	# are set to zero, but its x and y offsets are not changed.
	# 
	# As a side effect, the Rect is normalized.
	def clip!(rect)
		nself = self.normalize
		other = Rect.new_from_object(rect).normalize!
		if self.collide_rect?(other)
			self[0] = [nself.at(0), other.at(0)].max
			self[1] = [nself.at(1), other.at(1)].max
			self[2] = [nself.right, other.right].min - self.at(0)
			self[3] = [nself.bottom, other.bottom].min - self.at(1)
		else #if they do not intersect at all:
			self[0], self[1] = nself.topleft
			self[2], self[3] = 0, 0
		end
		return self
	end

	# Iterate through all key/value pairs in the given hash table, and
	# return the first pair whose value is a Rect that collides with the
	# caller.
	#
	# Because a hash table is unordered, you should not expect any 
	# particular Rect to be returned first.
	def collide_hash(hash_rects)
		hash_rects.each { |key,value|
			if value.collide_rect?+(self); return [key,value]; end
		}
		return nil
	end

	# Iterate through all key/value pairs in the given hash table, and
	# return an Array of every pair whose value is a Rect that collides
	# the caller.
	# 
	# Because a hash table is unordered, you should not expect the returned
	# pairs to be in any particular order.
	def collide_hash_all(hash_rects)
		hash_rects.select { |key,value|
			value.collide_rect?+(self)
		}
	end

	# Iterate through all elements in the given Array, and return
	# the *index* of the first element which is a Rect that collides with
	# the caller.
	def collide_array(array_rects)
		for i in (0...(array_rects.length))
			if array_rects[i].collide_rect?(self)
				return i
			end
		end
		return nil
	end

	# Iterate through all elements in the given Array, and return
	# an Array containing the *indices* of every element that is a Rect
	# that collides with the caller.
	def collide_array_all(array_rects)
		indexes = []
		for i in (0...(array_rects.length))
			if array_rects[i].collide_rect?(self)
				indexes += [i]
			end
		end
		return indexes
	end

	# True if the point is inside (including on the border) of the caller.
	# If you have Array of coordinates, you can use collide_point?(*coords).
	def collide_point?(x,y)
		nself = normalize()
		x.between?(nself.left,nself.right) && y.between?(nself.top,nself.bottom)
	end

	# True if the caller and the given Rect overlap (or touch) at all.
	def collide_rect?(rect)
		nself = self.normalize
		rect  = Rect.new_from_object(rect).normalize!
		return ((nself.l >= rect.l && nself.l <= rect.r) or (rect.l >= nself.l && rect.l <= nself.r)) &&
		       ((nself.t >= rect.t && nself.t <= rect.b) or (rect.t >= nself.t && rect.t <= nself.b))
	end

	# True if the given Rect is totally within the caller. Borders may
	# overlap.
	def contain?(rect)
		nself = self.normalize
		rect = Rect.new_from_object(rect).normalize!
		return (nself.left <= rect.left and rect.right <= nself.right and
					nself.top <= rect.top and rect.bottom <= nself.bottom)
	end

	# As #inflate!, but the original caller is not changed.
	def inflate(x,y)
		return self.class.new(self.at(0) - x.div(2),
													self.at(1) - y.div(2),
													self.at(2) + x,
													self.at(3) + y)
	end

	# Increase the Rect's size is the x and y directions, while keeping the
	# same center point. For best results, expand by an even number.
	# X and y inflation can be given as an Array or as separate values.
	def inflate!(x,y)
		self[0] -= x.div(2)
		self[1] -= y.div(2)
		self[2] += x
		self[3] += y
		return self
	end

	# As #move!, but the original caller is not changed.
	def move(x,y)
		self.dup.move!(x,y)
	end

	# Translate the Rect by the given amounts in the x and y directions.
	# Positive values are rightward for x and downward for y.
	# X and y movement can be given as an Array or as separate values.
	def move!(x,y)
		self[0]+=x; self[1]+=y
		return self
	end

	# As #normalize!, but the original caller is not changed.
	def normalize
		self.dup.normalize!()
	end

	# Fix Rects that have negative width or height, without changing the
	# area it represents. Has no effect on Rects with non-negative width
	# and height. Some Rect methods will automatically normalize the Rect.
	def normalize!
		if self.at(2) < 0
			self[0], self[2] = self.at(0)+self.at(2), -self.at(2)
		end
		if self.at(3) < 0
			self[1], self[3] = self.at(1)+self.at(3), -self.at(3)
		end
		self
	end

	# As #union!, but the original caller is not changed.
	def union(rect)
		self.dup.union!(rect)
	end

	# Expand the caller to also cover the given Rect. The Rect is still a 
	# rectangle, so it may also cover areas that neither of the original
	# Rects did, for example areas between the two Rects.
	def union!(rect)
		self.normalize!
    rleft, rtop = self.topleft
    rright, rbottom = self.bottomright
		r2 = Rect.new_from_object(rect).normalize!

		rleft = [rleft, r2.left].min
		rtop = [rtop, r2.top].min
		rright = [rright, r2.right].max
		rbottom = [rbottom, r2.bottom].max

		self[0,4] = rleft, rtop, rright - rleft, rbottom - rtop
		return self
	end

	# As #union_all!, but the original caller is not changed.
	def union_all(array_rects)
		self.dup.union_all!(array_rects)
	end

	# Expand the caller to cover all of the given Rects. See also #union!
	def union_all!(array_rects)
		array_rects.each do |r|
      self.union!(r)
		end
		return self
	end


end # class Rect


class Surface
	# Return a Rect with the same width and height as the Surface, positioned
	# at (0,0).
	def make_rect()
		return Rect.new(0,0,self.width,self.height)
	end
end

end # module Rubygame
