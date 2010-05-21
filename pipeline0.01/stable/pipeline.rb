#!/usr/bin/ruby

$path = "/home/jashi/pipeline/"
$vpath = "/home/jashi/pipeline/pipeline0.01/"

require 'optparse'
require "#{$vpath}stable/raw_to_mzxml.rb"
require "#{$vpath}stable/mzxml_to_other.rb"
require "#{$vpath}stable/search.rb"

class Pipeline
    def initialize(file, type, enzyme, output)
        @file = file
        @type = type
        @enzyme = enzyme
        @output = output
    end
    
    def run
        puts "\nHere we go!\n"
        
        RawTomzXML.new("#{@file}.raw", @output).convert
        MzXMLToOther.new("mgf", "#{@file}.mzXML", @output, true).convert
        output = Search.new("#{@file}.mgf", @output, @type, @enzyme, 1, :omssa => true, :xtandem => true, :crux => true, :sequest => true, :mascot => true).run
        
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

if ARGV.size < 3
    puts "\nusage: #{File.basename(__FILE__)} inputFile type enzyme (outputFolder)\n\n"
    puts "inputFile: The name of the .RAW file"
    puts "type: The type of sample, such as human, rat, or bovin"
    puts "enzyme: trypsin, chymotrypsin, ..."
    puts "outputFolder: The location for files to be stored. If not specified, defaults to /usr/local/pipeline/"
    exit
end

file = ARGV[0].chomp(".raw").chomp(".RAW")
temp = file.split("/")
name = temp[temp.length-1]
output = ""

if ARGV[3].to_s == ""
	output = "/usr/local/pipeline/" + name
else
	output = ARGV[3].to_s + name
end

Pipeline.new(file, ARGV[1], ARGV[2], output).run
