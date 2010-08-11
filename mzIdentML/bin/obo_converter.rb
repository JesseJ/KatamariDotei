require 'nokogiri'
require 'yaml'

# This program will convert the psi-ms.obo file into a format that's easier to parse.
# Creates the mzid_name and the pepxml_name to allow for conversion from pepxml names to mzid names. Sadly, pepxml names which
# differ from mzid names will have to be set by hand.


# Create yaml file
file = File.new("#{File.dirname($0)}/obo.yaml", "w")
obo = File.open("#{File.dirname($0)}/psi-ms.obo", "r")
yml = []

line = obo.readline

while !(line.include? "[Typedef]")
  if line[0..2] == "id:"
    name = obo.readline
    yml << {:pepxml_name => name[6...name.length-1], :id => line[4...line.length-1], :mzid_name => name[6...name.length-1]}
  end
  
  line = obo.readline
end

YAML.dump(yml, file)

obo.close
file.close
