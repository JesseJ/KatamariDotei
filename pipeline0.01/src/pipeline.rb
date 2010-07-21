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

# This is the main class of the pipeline.
class Pipeline
  # file == A string containing the location of the raw file
  # type == The type of input, e.g. human or bovin
  def initialize(file, database)
    @file = file
    @database = database
  end
    
  def run
    puts "\nHere we go!\n"
    
#    RawToMzml.new("#{@file}").to_mzML
#    [1,2,3,4].each do |i|
#      MzmlToOther.new("mgf", "#{@file}.mzML", i, false).convert
#      MzmlToOther.new("ms2", "#{@file}.mzML", i, false).convert
#      output = Search.new("#{@file}_#{i}", @database, "trypsin", :omssa => true, :xtandem => true, :tide => true, :mascot => true).run
#      output = Percolator.new(output, @database).run
#      GC.start
#      file = Combiner.new(output, i).combine
#      Refiner.new(file, 0.8, "#{@file}.mzML", i).refine
#      GC.start
#    end
    
    RawToMzml.new("#{@file}").to_mzML
    MzmlToOther.new("mgf", "#{@file}.mzML", 1, false).convert
    MzmlToOther.new("ms2", "#{@file}.mzML", 1, false).convert
    output = Search.new("#{@file}_1", @database, "trypsin", :omssa => true, :xtandem => true, :tide => true, :mascot => true).run
    output = Percolator.new(output, @database).run
    file = Combiner.new(output, 1).combine
    Refiner.new(file, 0.9, "#{@file}.mzML", 1).refine
    
#    a = "#{$path}../data/test_1_"
#    file = Combiner.new(["#{a}tide.psms", "#{a}omssa.psms", "#{a}tandem.psms", "#{a}mascot.psms"], 1).combine
#    Refiner.new(file, 0.8, "#{@file}.mzML", 1).refine
    
    notify_the_user_that_the_program_has_finished_by_calling_this_long_method_name
  end
    
  # Displays a randomly chosen exclamation of joy.
  def notify_the_user_that_the_program_has_finished_by_calling_this_long_method_name
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
    puts "--------------------------------\n"
  end
end

Pipeline.new(file, type).run
