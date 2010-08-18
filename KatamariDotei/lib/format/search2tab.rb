require "#{$path}format/pepxml.rb"
require "#{$path}format/mzidentml.rb"

# Turns a search engine output (e.g. pepXML) into a tab-delimited file for Percolator.
class Search2Tab
  # format == A Format object
  def initialize(format)
    @format = format
  end
  
  # Converts the given file into a .tab file, returning the name of the file.
  def convert
    name = @format.fileWithoutExtras
    tab = File.new("#{name}.tab", "w")
    matches = @format.matches
    
    tab.puts @format.header
    matches.each {|match| tab.puts match}
    
    tab.close
    
    return name
  end
end
