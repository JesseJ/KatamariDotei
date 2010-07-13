#!/usr/bin/ruby

$path = "#{File.dirname($0)}/"

require "#{$path}raw_to_mzml.rb"
require "#{$path}mzml_to_other.rb"
require "#{$path}search.rb"
require "#{$path}refiner.rb"
require "#{$path}percolator.rb"
require "#{$path}combiner.rb"
require "#{$path}helper_methods.rb"

#file = "#{File.expand_path($path)}/../data/fast"
file = "#{File.expand_path($path)}/../data/test"

type = "human"

#Main
class Pipeline
  #This is the main class of the pipeline.
  #file == A string containing the location of the raw file
  #type == The type of input, e.g. human or bovin
  def initialize(file, type)
    @file = file
    @type = type
  end
    
  def run
    puts "\nHere we go!\n"
    
    RawToMzml.new("#{@file}").to_mzML
    MzmlToOther.new("mgf", "#{@file}.mzML", false).convert
    MzmlToOther.new("ms2", "#{@file}.mzML", false).convert
    output = Search.new("#{@file}", @type, "trypsin", 1, :omssa => true, :xtandem => true, :tide => true, :mascot => true).run
    output = Percolator.new(output, @type).run
    #Refiner.new(output, 0, "#{@file}.mzML").refine
    a = "#{$path}../data/test_"
    file = Combiner.new(["#{a}tide_1.psms", "#{a}omssa_1.psms", "#{a}tandem_1.psms", "#{a}mascot_1.psms"], 1).combine
    Refiner.new(file, 0.5, "#{@file}.mzML").refine
    
    notifyCompletion
  end
    
  #Displays a randomly chosen exclamation of joy.
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
