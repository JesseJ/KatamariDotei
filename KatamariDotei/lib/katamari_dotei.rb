#!/usr/bin/ruby

$path = "#{File.expand_path(File.dirname(__FILE__))}/"
$: << $path

require "raw_to_mzml"
require "mzml_to_other"
require "search"
require "refiner"
require "percolator"
require "combiner"
require "resolver"
require "helper_methods"
require "#{$path}../../mzIdentML/search2mzidentml.rb"
require 'nokogiri'

# This is the main class of the pipeline.
class KatamariDotei
  # file == A string containing the location of the raw file
  # type == The type of input, e.g. human or bovin
  # config == The config file
  def initialize(file, database, config)
    @file = file
    @database = database
    @fileName = File.basename(file)
    @dataPath = "#{$path}../data/"
    $config = Nokogiri::XML(IO.read(config))
  end
  
  def run
    puts "\nHere we go!\n"
    
    if config_value("//Format/@type") == "mzML"
      RawToMzml.new("#{@file}").to_mzML
    else
      RawToMzml.new("#{@file}").to_mzXML
    end
    
    iterations.each do |i|
      runHardklor = config_value("//Hardklor/@run")
      MzmlToOther.new("mgf", "#{@dataPath}/spectra/#{@fileName}.mzML", i[0], runHardklor).convert
      MzmlToOther.new("ms2", "#{@dataPath}/spectra/#{@fileName}.mzML", i[0], runHardklor).convert
      output = Search.new("#{@dataPath}/spectra/#{@fileName}_#{i[0]}", @database, i[1], selected_search_engines).run
      convert_to_mzIdentML(output)
      output = Percolator.new(output, @database).run
      GC.start
      file = Combiner.new(output, i[0]).combine
      Refiner.new(file, config_value("//Refiner/@cutoff").to_i, "#{@dataPath}/spectra/#{@fileName}.mzML", i[0]).refine
      GC.start
      Resolver.new(file).resolve
    end
  
    tell_the_user_that_the_program_has_like_totally_finished_doing_its_thang_by_calling_this_butt_long_method_name_man
  end
  
  
  private
  
  # Obtains the iteration information from the config file.
  def iterations
    array = []
    $config.xpath("//Iteration").each {|x| array << [x.xpath("./@run").to_s.to_i, x.xpath("./@enzyme").to_s]}
    
    array
  end
  
  # Creates the hash that states which search engines to run.
  def selected_search_engines
    {:omssa => s_true(config_value("//OMSSA/@run")),
     :xtandem => s_true(config_value("//XTandem/@run")),
     :tide => s_true(config_value("//Tide/@run")),
     :mascot => s_true(config_value("//Mascot/@run"))}
  end
  
  # Method name says it all
  def convert_to_mzIdentML(files)
    files.each do |pair|
      pair.each {|file| Search2mzIdentML.new(PepXML.new(file, extractDatabase(@database))).convert}
    end
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
