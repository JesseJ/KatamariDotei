require "#{$path}search2tab.rb"

#Runs Percolator
class Percolator
  #files == The output from Search
  #type == The type of database, e.g. human or bovin
  def initialize(files, type)
    @files = files
    @type = type
  end
  
  #Runs percolator on the given files
  def run
    puts "\n----------------"
    puts "Running Percolator...\n\n"
    
    database = extractDatabase(@type).chomp("fasta") + "yml"
    revDatabase = extractDatabase(@type + "-r").chomp("fasta.reverse") + "yml"
    @proteins = Hash.new
    @decoyProteins = Hash.new
    
    File.open(database, "r").each_line do |line|
      parts = line.split(": ")
      @proteins[parts[0]] = parts[1]
    end
    
    File.open(revDatabase, "r").each_line do |line|
      parts = line.split(": ")
      @decoyProteins[parts[0]] = parts[1]
    end
    
    @files.each do |pair|
      output = Search2Tab.new(PepXML.new(pair[0], pair[1], @proteins, @decoyProteins)).convert
      exec("percolator -j #{output}.tab > #{output}.psms") if fork == nil
    end
    
    waitForAllProcesses
  end
end

#YAML: 4:41 +extra
#Own w/YAML: 2:47 +extra
#modified tsv: 1:54
#* method: 4:39 +extra
#Own split: 3:14