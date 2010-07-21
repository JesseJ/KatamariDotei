require 'socket'

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
    
    system("wine readw.exe --mzXML #{@file}.raw 2>/dev/null")
  end
  
  # Converts file to mzML. There must also be msconvert_server.rb running on
  # a Windows machine with msconvert.exe for this to work.
  def to_mzML
    puts "\n--------------------------------"
    puts "Transforming raw file to mzML format...\n\n"
    
    host = '192.168.101.180'  #The address of the Windows machine I'm using.
    port = 2000
    
    client = TCPSocket.open(host, port)

    fileName = @file.split("/")[-1]
    
    puts "Sending raw file"
    client.puts fileName
    client.print(File.open("#{@file}.raw", "rb") {|io| io.read})
    client.print("\r\r\n\n")  #This is the delimiter for the server
    
    puts "Receiving mzML file"
    File.open("#{$path}../data/#{fileName}.mzML", 'wb') {|io| io.print client.gets("\r\r\n\n")}
    client.close
  end
end
