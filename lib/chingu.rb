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

CHINGU_ROOT = File.dirname(File.expand_path(__FILE__))
ROOT = File.dirname(File.expand_path($0))

require 'rubygems' unless RUBY_VERSION =~ /1\.9/
require 'gosu'
require 'yaml'
require 'rest_client'
require 'crack/xml'

require File.join(CHINGU_ROOT,"chingu","require_all") # Thanks to http://github.com/tarcieri/require_all !

# Seems like we need to include chingu/helpers first for BasicGameObject
# and GameObject to get the correct class_inheritable_accssor
require_all "#{CHINGU_ROOT}/chingu/helpers"
require_all "#{CHINGU_ROOT}/chingu/traits"
require_all "#{CHINGU_ROOT}/chingu"

module Chingu
  VERSION = "0.8.1"
  
  DEBUG_COLOR = Gosu::Color.new(0xFFFF0000)
  DEBUG_ZORDER = 9999
  INFINITY = 1.0 / 0
end