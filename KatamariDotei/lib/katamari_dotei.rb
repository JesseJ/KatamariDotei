#!/usr/bin/ruby

Sample = Struct.new(:mzml, :mgfs, :searches, :percolator, :combined)
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
require "#{$path}../../mzIdentML/lib/search2mzidentml.rb"
require 'nokogiri'

# This is the main class of the pipeline.
class KatamariDotei
  # file == A string containing the location of the raw file
  # type == The type of input, e.g. human or bovin
  # config == The config file
  def initialize(files, database, config)
    @files = files
    @database = database
    @dataPath = File.expand_path("#{$path}../data/") + "/"
    $config = Nokogiri::XML(IO.read(config))
  end
  
  def run
    puts "\nHere we go!\n"
    
    runHardklor = config_value("//Hardklor/@run")
    mzType = config_value("//Format/@type")
    cutoff = config_value("//Refiner/@cutoff").to_f
    samples = {}
    
    @files.each do |file|
      fileName = File.basename(file).chomp(File.extname(file))
      samples[fileName] = Sample.new(fileName, [], [], [], [])
      iterations = get_iterations
      
      if mzType == "mzML"
        RawToMzml.new("#{file}").to_mzML
      else
        RawToMzml.new("#{file}").to_mzXML
      end
      
      mzFile = "#{@dataPath}spectra/#{fileName}.#{mzType}"
      samples[fileName].mgfs << MzmlToOther.new("mgf", mzFile, iterations[0][0], s_true(runHardklor)).convert
      MzmlToOther.new("ms2", mzFile, iterations[0][0], s_true(runHardklor)).convert
      
      iterations.each do |i|
        GC.start  #Fork will fail if there's not enough memory. This is an attempt to help.
        samples[fileName].searches << Search.new(samples[fileName].mgfs[-1].chomp(".mgf"), @database, i[1], selected_search_engines).run
        convert_to_mzIdentML(samples[fileName].searches[-1])
        GC.start
        samples[fileName].percolator << Percolator.new(samples[fileName].searches[-1], @database).run
        GC.start
        samples[fileName].combined << Combiner.new(samples[fileName].percolator[-1], fileName, i[0]).combine
        samples[fileName].mgfs << Refiner.new(samples[fileName].combined[-1], cutoff, mzFile, iterations[i[2]+1][0]).refine if i[2] < iterations.length-1
        GC.start
      end
    end
    
    Resolver.new(samples).resolve
    
    tell_the_user_that_the_program_has_like_totally_finished_doing_its_thang_by_calling_this_butt_long_method_name_man
  end
  
  
  private
  
  # Obtains the iteration information from the config file.
  def get_iterations
    array = []
    i = 0
    
    $config.xpath("//Iteration").each do |x|
      array << [x.xpath("./@run").to_s, x.xpath("./@enzyme").to_s, i]
      i += 1
    end
    
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
