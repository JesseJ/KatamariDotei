require "#{$path}pepxml.rb"

class Search2Tab
  def initialize(format)
    @format = format
  end
    
  def convert
    tab = File.new("#{@format.file}.tab", "w+")
    matches = @format.matches
    
    tab.puts header(matches[0])
    
    matches.each do |match|
      tab.puts match
    end
    
    tab.close
    
    return "#{@format.file}"
  end
  
  
  private
  
  #Dynamically creates a header for the given file, but uses generic score names.
  def header(match)
    result = "SpecId\tLabel\tCharge\t"
    scores = match.split("\t").length - 5
    
    1.upto(scores) {|i| result += "Score#{i}\t"}
    
    result += "Peptide\t" + "Proteins"
  end
end
