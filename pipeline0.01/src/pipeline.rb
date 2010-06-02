#!/usr/bin/ruby

$path = "#{File.dirname($0)}/"

require "#{$path}raw_to_mzxml.rb"
require "#{$path}mzxml_to_other.rb"
require "#{$path}search.rb"
require "#{$path}false_rate_discoverer.rb"
require "#{$path}refiner.rb"

#file = "#{File.expand_path($path)}/../data/fast"
file = "#{File.expand_path($path)}/../data/test"

type = "human"

class Pipeline
    def initialize(file, type)
        @file = file
        @type = type
    end
    
    def run
        puts "\nHere we go!\n"
        
        RawTomzXML.new("#{@file}.raw").convert
        MzXMLToOther.new("mgf", "#{@file}.mzXML", false).convert
        MzXMLToOther.new("ms2", "#{@file}.mzXML", false).convert
        output = Search.new("#{@file}", @type, "trypsin", 1, :omssa => false, :xtandem => false, :tide => true, :sequest => true, :mascot => true).run
        qValues = FalseRateDiscoverer.new([["#{@file}-forward_omssa_1.pep.xml", "#{@file}-decoy_omssa_1.pep.xml"]]).discoverFalseRate
        #qValues = FalseRateDiscoverer.new(output).discoverFalseRate
        Refiner.new("#{@file}-forward_omssa_1.pep.xml", qValues, 0.01).refine
        #Refiner.new(output, qValues)
        
        notifyCompletion
    end
    
    def notifyCompletion
        done = rand(11)
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
        puts "----------------\n"
    end
end

Pipeline.new(file, type).run
