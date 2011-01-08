#!/usr/bin/env ruby
require 'rubygems'
require 'benchmark'

  
@array = []
@hash = {}
Benchmark.bm(22) do |x|
  x.report('add/remove from array') { 100000.times { |nr| @array.push(nr); @array.delete(nr-1) if nr > 100 } }
  x.report('add/remove from hash') { 100000.times { |nr| @hash[nr] = true; @hash.delete(nr-1) if nr > 100 } }
  
  @array.clear
  @hash.clear
  x.report('add to array') { 100000.times { |nr| @array.push(nr) } }
  x.report('add to hash')  { 100000.times { |nr| @hash[nr] = true } }
  
  x.report('array.each') { 100.times { |nr| @array.each { |x| x } } }
  x.report('hash.each') { 100.times { |nr| @hash.each { |k,v| k } } }
  x.report('hash.each_key') { 100.times { |nr| @hash.each_key { |x| x } } }
end
