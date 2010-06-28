
#Transforms a .raw file to a mzXML or mzML file
class RawToMz
  def initialize(file)
    @file = file
  end
  
  def to_mzXML
    puts "\n----------------"
    puts "Transforming raw file to mzXML format...\n\n"

    system("wine readw.exe --mzXML #{@file}.raw 2>/dev/null")
  end
  
  def to_mzML
    puts "\n----------------"
    puts "Transforming raw file to mzML format...\n\n"
    
    host = '192.168.101.180'
    port = 2000
    
    client = TCPSocket.open(host, port)
    parts = @file.split("/")
    
    puts "Sending raw file"
    client.puts parts[parts.length-1]
    client.print(File.open("#{@file}.raw", "rb") {|io| io.read})
    client.print("\r\r\n\n")  #This is the delimiter for the server
    
    puts "Receiving mzML file"
    mzML_filename = client.gets("\n")
    File.open("#{$path}../data/#{mzML_filename}", 'wb') {|io| io.print client.gets("\r\r\n\n")}
    client.close
  end
end
