$path = "/home/jashi/pipeline/"
$vpath = "/home/jashi/pipeline/pipeline0.01/"

require "#{$vpath}src/raw_to_mzxml.rb"
require "#{$vpath}src/mzxml_to_other.rb"
require "#{$vpath}src/search.rb"
require "#{$vpath}src/false_rate_discoverer.rb"
require "#{$vpath}src/refiner.rb"

#file = "#{$vpath}data/small"
file = "#{$vpath}data/ABRF"

class Pipeline
    def initialize(file)
        @file = file
    end
    
    def run
        RawTomzXML.new("#{@file}.raw").convert
        MzXMLToOther.new("mgf", "#{@file}.mzXML", false).convert
        output = Search.new("#{@file}.mgf", "human", "trypsin", 1, :omssa => true, :xtandem => true, :crux => true, :sequest => true, :mascot => true).run
        qValues = FalseRateDiscoverer.new([["#{@file}-forward_tandem_output_1.pep.xml", "#{@file}-decoy_tandem_output_1.pep.xml"]]).discoverFalseRate
        #qValues = FalseRateDiscoverer.new(output).discoverFalseRate
        #Refiner.new("#{@file}-forward_omssa_output_1.pep.xml", qValues, 0.01).refine
        #Refiner.new(output, qValues)
        
        notifyCompletion
    end
    
    def notifyCompletion
        done = rand(10)
        puts "\nBoo-yah!" if done == 0
        puts "\nOh-yeah!" if done == 1
        puts "\nWhoo-hoo!" if done == 2
        puts "\nYeah-yuh!" if done == 3
        puts "\nRock on!" if done == 4
        puts "\n^_^" if done == 5
        puts "\nRadical!" if done == 6
        puts "\nAwesome!" if done == 7
        puts "\nTubular!" if done == 8
        puts "\nYay!" if done == 9
        puts "----------------\n"
    end
end

Pipeline.new(file).run