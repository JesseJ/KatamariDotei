#!/usr/bin/ruby

$path = "#{File.dirname($0)}/../lib/"

require "#{$path}raw_to_mzml.rb"
require "#{$path}mzml_to_other.rb"
require "#{$path}search.rb"
require "#{$path}refiner.rb"
require "#{$path}percolator.rb"
require "#{$path}combiner.rb"
require "#{$path}resolver.rb"
require "#{$path}helper_methods.rb"
require 'nokogiri'

# This is the main class of the pipeline.
class KatamariDotei
  # file == A string containing the location of the raw file
  # type == The type of input, e.g. human or bovin
  # config == The config file
  def initialize(file, database, config)
    @file = file
    @database = database
    @config = config
    @fileName = File.basename(file)
    @dataPath = "#{$path}/../data/"
    @doc = Nokogiri::XML(IO.read(config))
  end
    
  def run
    puts "\nHere we go!\n"
    
    RawToMzml.new("#{@file}").to_mzML
    iterations.each do |i|
      MzmlToOther.new("mgf", "#{@dataPath}/spectra/#{@fileName}.mzML", i[0], false).convert
      MzmlToOther.new("ms2", "#{@dataPath}/spectra/#{@fileName}.mzML", i[0], false).convert
      output = Search.new("#{@dataPath}/spectra/#{@fileName}_#{i[0]}", @database, i[1], selected_search_engines).run
      output = Percolator.new(output, @database).run
      GC.start
      file = Combiner.new(output, i[0]).combine
      Refiner.new(file, @doc.xpath("//Refiner/@cutoff").to_s, "#{@dataPath}/spectra/#{@fileName}.mzML", i[0]).refine
      GC.start
      Resolver.new(file).resolve
    end
  
    tell_the_user_that_the_program_has_like_totally_finished_doing_its_thang_by_calling_this_butt_long_method_name_man
  end
  
  
  private
  
  # Obtains the iteration information from the config file.
  def iterations
    array = []
    @doc.xpath("//Iteration").each {|x| array << [x.xpath("./@run").to_s.to_i, x.xpath("./@enzyme").to_s]}
    
    array
  end
  
  # Creates the hash that states which search engines to run.
  def selected_search_engines
    {:omssa => s_true(@doc.xpath("//OMSSA/@run").to_s),
     :xtandem => s_true(@doc.xpath("//XTandem/@run").to_s),
     :tide => s_true(@doc.xpath("//Tide/@run").to_s),
     :mascot => s_true(@doc.xpath("//Mascot/@run").to_s)}
  end
  
  # Displays a randomly chosen exclamation of joy.
  def tell_the_user_that_the_program_has_like_totally_finished_doing_its_thang_by_calling_this_butt_long_method_name_man
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
