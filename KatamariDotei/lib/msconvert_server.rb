require 'socket'

server = TCPServer.open(2200) # Socket to listen on port 2200
loop { # Servers run forever
  client = server.accept
  
  filename = client.gets.chomp
  
  # A small attempt at preventing shell injection. Do we even need security on this?
  if filename.include?("|") || filename.include?("&") || filename.include?("/") || filename.include?(".exe")
    client.puts "Get lost, hacker!"
    client.close
    next
  end
  
  puts "Reading contents of #{filename}.raw"
  raw_data = client.gets("\r\r\n\n").chomp("\r\r\n\n")  # "\r\r\n\n" is the delimiter of the data stream.
  file = File.open(filename + ".raw", 'wb')
  file.print raw_data
  file.close
  
  puts "Converting #{filename}"
  # It's lame to have a script run a script, but it's the only way to get this to work.
  system "scriptit.bat " + filename + ".raw"
  
  puts "Sending contents of #{filename}.mzML"
  data = IO.read(filename + ".mzML")
  client.print data
  client.print "\r\r\n\n"
  
  puts "Done"
  client.close # Disconnect from the client
}
