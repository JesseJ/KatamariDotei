require "#{$path}pepxml.rb"

class Search2Tab
  def initialize(format)
    @format = format
  end
    
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