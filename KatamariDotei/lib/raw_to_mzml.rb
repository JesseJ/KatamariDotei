require 'socket'
require "helper_methods"

# Transforms a .raw file to a mzXML or mzML file
class RawToMzml
  # file == A string containing the file location (Without extension)
  def initialize(file)
    @file = file
  end
  
  # Converts file to mzXML
  def to_mzXML
    puts "\n--------------------------------"
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
    port = 2000
    
    client = TCPSocket.open(host, port)

    fileName = @file.split("/")[-1].chomp(File.extname(@file))
    
    puts "Sending raw file"
    client.puts fileName
    client.print(File.open("#{@file}", "rb") {|io| io.read})
    client.print("\r\r\n\n")  #This is the delimiter for the server
    
    puts "Receiving mzML file"
    File.open("#{$path}../data/spectra/#{fileName}.mzML", 'wb') {|io| io.print client.gets("\r\r\n\n")}
    client.close
  end
end
