#!/usr/bin/ruby

require "#{File.dirname($0)}/../lib/katamari_dotei"

if ARGV.size < 2
    puts "\nusage: #{File.basename(__FILE__)} rawFile databaseID [configFile]"
    puts "rawFile: The location of the raw file to run on. Can take more than one raw file"
    puts "databaseID: The type of input, e.g. human or bovin"
    puts "configFile: The location of the config file. If not specified, defaults to pipeline/config.xml"
    exit
end

# Sort out the input
raw_files = []
dbID = ""
config = "#{File.dirname($0)}/../../config.xml"

ARGV[0..-1].each do |param|
  p param
   if param.downcase.include? ".raw"
     raw_files << param
   elsif param.downcase.include? ".xml"
     config = param
   else
     dbID = param
   end
end

# Run KatamariDotei on each of the given raw files
raw_files.each do |raw_file|
  KatamariDotei.new(raw_file.chomp(".raw").chomp(".RAW"), dbID, config).run
end
