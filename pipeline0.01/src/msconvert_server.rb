require 'socket'

server = TCPServer.open(2000) # Socket to listen on port 2000
loop { # Servers run forever
  client = server.accept
  
  filename = client.gets.chomp
  puts "Reading contents of #{filename}.raw"
  raw_data = client.gets("\r\r\n\n").chomp("\r\r\n\n")
  File.open(filename + ".raw", 'wb') {|out| out.print raw_data}
  puts "Converting #{filename}"
  
  #It's lame to have a script run a script, but it's the only way to get this to work.
  system "scriptit.bat " + filename + ".raw"
  
  puts "Sending filename"
  client.print filename + ".mzML\n"
  puts "Sending contents of #{filename}.mzML"
  client.print IO.read(filename + ".mzML")
  client.print "\r\r\n\n"
  puts "Done"
  client.close # Disconnect from the client
}
