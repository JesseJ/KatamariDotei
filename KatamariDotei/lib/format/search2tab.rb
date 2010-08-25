require "#{$path}format/pepxml.rb"
require "#{$path}format/mzidentml.rb"

# Turns a search engine output (e.g. pepXML) into a tab-delimited file for Percolator.
#
# @author Jesse Jashinsky (Aug 2010)
class Search2Tab
  # @param [Format] format a Format object
  def initialize(format)
    @format = format
  end
  
  # Converts the given file into a .tab file, returning the name of the file.
  def convert
    name = @format.fileWithoutExtras
    tab = File.new("#{name}.tab", "w")
    matches = @format.matches
    
    # The tab files requires a header followed by spectral matches.
    tab.puts @format.header
    matches.each {|match| tab.puts match}
    
    tab.close
    
    return name
  end
end
