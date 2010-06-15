require "#{$path}search2tab.rb"

class Percolator
  def initialize(files)
    @files = files
  end
  
  #Runs percolator on the given files
  def run
    puts "\n----------------"
    puts "Running Percolator...\n"
    
    @files.each do |pair|
      output = Search2Tab.new(PepXML.new(pair[0], pair[1])).convert
      exec("percolator -j #{output}.tab > #{output}.psms") if fork == nil
    end
    
    waitForAllProcesses
  end
end