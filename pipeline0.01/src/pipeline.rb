#!/usr/bin/ruby

$path = "#{File.dirname($0)}/"

require "#{$path}raw_to_mz.rb"
require "#{$path}mzxml_to_other.rb"
require "#{$path}search.rb"
require "#{$path}false_rate_discoverer.rb"
require "#{$path}refiner.rb"
require "#{$path}percolator.rb"
require "#{$path}helper_methods.rb"

#file = "#{File.expand_path($path)}/../data/fast"
file = "#{File.expand_path($path)}/../data/test"

type = "human"

#This is the main class of the pipeline.
class Pipeline
  def initialize(file, type)
    @file = file
    @type = type
  end
    
  def run
    puts "\nHere we go!\n"
    
    RawToMz.new("#{@file}").to_mzXML
    #RawToMz.new("#{@file}").to_mzML
    MzXMLToOther.new("mgf", "#{@file}.mzXML", false).convert
    MzXMLToOther.new("ms2", "#{@file}.mzXML", false).convert
    #output = Search.new("#{@file}", @type, "trypsin", 1, :omssa => true, :xtandem => true, :tide => true, :mascot => true).run
    #Percolator.new(output, @type).run
    
    notifyCompletion
  end
    
  #Displays a randomly chosen exclamation of joy
  def notifyCompletion
    done = rand(13)
    puts "\nBoo-yah!" if done == 0
    puts "\nOh-yeah!" if done == 1
    puts "\nYah-hoo!" if done == 2
    puts "\nYeah-yuh!" if done == 3
    puts "\nRock on!" if done == 4
    puts "\n^_^" if done == 5
    puts "\nRadical!" if done == 6
    puts "\nAwesome!" if done == 7
    puts "\nTubular!" if done == 8
    puts "\nYay!" if done == 9
    puts "\nGnarly!" if done == 10
    puts "\nSweet!" if done == 11
    puts "\nGroovy!" if done == 12
    puts "----------------\n"
  end
end

Pipeline.new(file, type).run
