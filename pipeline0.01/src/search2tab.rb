require "#{$path}pepxml.rb"

#Turns a search engine output (e.g. pepXML) into a tab-delimited file for Percolator.
class Search2Tab
  #format == A Format object
  def initialize(format)
    @format = format
  end
  
  #Converts the given file into a .tab file, returning the name of the file.
  def convert
    tab = File.new("#{@format.fileWithoutExtras}.tab", "w")
    matches = @format.matches
    
    tab.puts @format.header
    
    matches.each do |match|
      tab.puts match
    end
    
    tab.close
    
    return "#{@format.fileWithoutExtras}"
  end
end
