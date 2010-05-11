$path = "/home/jashi/pipeline/"
$vpath = "/home/jashi/pipeline/pipeline0.01/"

require "#{$vpath}src/raw_to_mzxml.rb"
require "#{$vpath}src/mzxml_to_other.rb"
require "#{$vpath}src/search.rb"
require "#{$vpath}src/false_rate_discoverer.rb"
require "#{$vpath}src/refiner.rb"

#file = "#{$vpath}data/043010_100430153139"
file = "#{$vpath}data/ABRF_20femtomolul_10ul_orb1"
#file = "#{$vpath}data/JP_KB_2D_20091012_5uL_fraction2"
#RawTomzXML.new("#{file}.raw").convert
#MzXMLToOther.new("mgf", "#{file}.mzXML", false).convert
#output = Search.new("#{file}.mgf", "human", "trypsin", 1, :omssa => true, :xtandem => true, :crux => true, :sequest => true, :mascot => true).run
qValues = FalseRateDiscoverer.new([["#{file}-forward_omssa_output.pep.xml", "#{file}-decoy_omssa_output.pep.xml"]]).discoverFalseRate
#qValues = FalseRateDiscoverer.new(output).discoverFalseRate
#Refiner.new(output, qValues)
Refiner.new("#{file}-forward_omssa_output.pep.xml", qValues, 0.1).refine


done = rand(6)
puts "\nBoo-yah!" if done == 0
puts "\nOh-yeah!" if done == 1
puts "\nWhoo-hoo!" if done == 2
puts "\nYeah-yuh!" if done == 3
puts "\nRock on!" if done == 4
puts "\n^_^" if done == 5
puts "----------------\n"
