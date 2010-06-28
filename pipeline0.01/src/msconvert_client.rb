require 'socket'

host = '192.168.101.180'
port = 2000

client = TCPSocket.open(host, port)

client.puts "test"
client.print(File.open("/home/jashi/pipeline/pipeline0.01/data/test.raw", "rb") {|io| io.read})
client.print("\r\r\n\n")
mzML_filename = client.gets("\n")
File.open(mzML_filename, 'wb') {|io| io.print client.gets("\r\r\n\n")}
client.close