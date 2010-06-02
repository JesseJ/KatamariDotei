require 'nokogiri'

file = File.new("#{File.dirname($0)}/obo.xml", "w+")
obo = File.open("#{File.dirname($0)}/psi-ms.obo", "r")

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
	xml.obo(:version => obo.readline[16..18], :date => obo.readline[6..21]) {
		line = obo.readline
		
		while !(line.include? "[Typedef]")
			if line[0..2] == "id:"
				name = obo.readline
				xml.term(:id => line[4...line.length-1], :name => name[6...name.length-1])
			end
			
			line = obo.readline
		end
	}
end
		
file.puts builder.to_xml
obo.close
file.close