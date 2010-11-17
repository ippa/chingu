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

require_rel 'helpers/*'
module Chingu
  #
  # GameObject inherits from BasicGameObject to get traits and some class-methods like .all and .destroy
  # On top of that, it encapsulates GOSUs Image#draw_rot and all its parameters.
  # In Chingu GameObject is a visual object, something to put on screen, centers around the .image-parameter.
  # If you wan't a invisible object but with traits, use BasicGameObject.
  #
  class GameObject < Chingu::BasicGameObject
    trait :sprite
    include Chingu::Helpers::InputClient        # Adds input and input=
  end
end