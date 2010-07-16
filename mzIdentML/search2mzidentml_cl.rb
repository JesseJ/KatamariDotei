#!/usr/bin/ruby
#This file should have a better name

require 'optparse'
require "#{File.dirname($0)}/search2mzidentml.rb"
require "#{File.dirname($0)}/pepxml.rb"

#options = {:infile => "",
#           :database => ""}
#format = ""
#
#optparse = OptionParser.new do |opts|
#  opts.banner = "usage: #{File.basename(__FILE__)} inputFile [outputFile]"
#  
#  opts.on('-i', '--inFile FILE', 'The file to convert') do |file|
#    options[:infile] = file
#  end
#  
#  opts.on('-d', '--database FILE', 'The peptide database that was used in the search engine to create the inFile') do |file|
#    options[:database] = file
#  end
#  
#  opts.on('-h', '--help', 'Display this screen') do
#    puts opts
#    exit
#  end
#  
#  if options[:infile] == "" || options[:database] == ""
#    p options[:infile]
#    puts opts
#    exit
#  end
#end
#
#optparse.parse!

#Determine the format by the file's extension
#if options[:infile].downcase.include?("pepxml") || options[:infile].downcase.include?("pep.xml")
#  format = PepXML.new(options[:infile], options[:database])
#end

if ARGV.size != 2
  puts "\nusage: #{File.basename(__FILE__)} inputFile database"
  puts "inputFile: The location of the file to turn into mzIdentML (Currently only supports pepXML)"
  puts "database: The location of the FASTA database\n\n"
  exit
end

begin
  format = PepXML.new(ARGV[0], ARGV[1])
  Search2mzIdentML.new(format).convert
rescue
  $stderr.print "\n\tError: #{$!}\n"
end
