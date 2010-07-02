require 'socket'

#The server to be placed on a Windows machine in the same folder as msconvert.exe
#to transform raw files into mzML files.
server = TCPServer.open(2000) # Socket to listen on port 2000
loop { # Servers run forever
  client = server.accept
  
  filename = client.gets.chomp
  
  #A small attempt at preventing shell injection. Do we even need security on this?
  if filename.include?("|") || filename.include?("&") || filename.include?("/") || filename.include?(".exe")
    client.puts "Get lost, hacker!"
    client.close
    next
  end
    
  puts "Reading contents of #{filename}.raw"
  raw_data = client.gets("\r\r\n\n").chomp("\r\r\n\n")
  File.open(filename + ".raw", 'wb') {|out| out.print raw_data}
  puts "Converting #{filename}"
  
  #It's lame to have a script run a script, but it's the only way to get this to work.
  system "scriptit.bat " + filename + ".raw"
  
  puts "Sending contents of #{filename}.mzML"
  client.print IO.read(filename + ".mzML")
  client.print "\r\r\n\n"
  puts "Done"
  client.close # Disconnect from the client
}
