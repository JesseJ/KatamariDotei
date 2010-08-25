require 'socket'
require "helper_methods"

# Transforms a .raw file to a mzXML or mzML file
#
# @author Jesse Jashinsky (Aug 2010)
class RawToMzml
  # @param [String] file the file location of the .raw file (Without extension)
  def initialize(file)
    @file = file
  end
  
  # Converts file to mzXML
  def to_mzXML
    puts "\n--------------------------------"  # These puts statements at the begining of each class is my way of showing the progress of the program to the user.
    puts "Transforming raw file to mzXML format...\n\n"
    
    options = config_value("//ReAdW/@commandLine")
    basename = File.basename(@file).chomp(File.extname(@file))
    system("wine readw.exe #{options} --mzXML #{@file} #{$path}../data/spectra/#{basename}.mzXML 2>/dev/null")
  end
  
  # Converts file to mzML. There must also be msconvert_server.rb running on
  # a Windows machine with msconvert.exe for this to work.
  def to_mzML
    puts "\n--------------------------------"
    puts "Transforming raw file to mzML format...\n\n"
    
    host = config_value("//Host/@ip")
    port = 2200  # Completely arbitrary
    
    client = TCPSocket.open(host, port)

    fileName = @file.split("/")[-1].chomp(File.extname(@file))
    
    puts "Sending raw file"
    client.puts fileName
    data = IO.read(@file)
    client.print data
    client.print "\r\r\n\n"  #This is the delimiter for the server
    
    puts "Receiving mzML file"
    file = File.open("#{$path}../data/spectra/#{fileName}.mzML", 'wb')
    data = client.gets("\r\r\n\n")
    file.print data
    
    client.close
  end
end
