require "#{$path}search2tab.rb"

class Percolator
  def initialize(files, type)
    @files = files
    @type = type
  end
  
  #Runs percolator on the given files
  def run
    puts "\n----------------"
    puts "Running Percolator...\n"
    
    database = extractDatabase(@type).chomp("fasta") + "yml"
    revDatabase = extractDatabase(@type + "-r").chomp("fasta.reverse") + "yml"
    
    @proteins = YAML.load_file(database)
    @decoyProteins = YAML.load_file(revDatabase)
    
    @files.each do |pair|
      output = Search2Tab.new(PepXML.new(pair[0], pair[1], @proteins, @decoyProteins)).convert
      exec("percolator -j #{output}.tab > #{output}.psms") if fork == nil
    end
    
    waitForAllProcesses
  end
end