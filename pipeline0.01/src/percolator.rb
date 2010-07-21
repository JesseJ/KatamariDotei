require "#{$path}search2tab.rb"
require "#{$path}helper_methods.rb"

# Runs Percolator
class Percolator
  # files == The output from Search
  # type == The type of database, e.g. human or bovin
  def initialize(files, type)
    @files = files
    @type = type
  end
  
  # Runs percolator on the given files
  def run
    puts "\n--------------------------------"
    puts "Running Percolator...\n\n"
    
    database = extractDatabase(@type).chomp("fasta") + "yml"
    revDatabase = extractDatabase(@type + "-r").chomp("fasta.reverse") + "yml"
    @proteins = Hash.new
    @decoyProteins = Hash.new
    outputs = []
    threads = []
    
    #This, and the part for decoyProteins, takes quite some time. Unfortunately,
    #I haven't found any way to speed it up more than this.
    File.open(database, "r").each_line do |line|
      parts = line.split(": ")
      @proteins[parts[0]] = parts[1]
    end
    
    File.open(revDatabase, "r").each_line do |line|
      parts = line.split(": ")
      @decoyProteins[parts[0]] = parts[1]
    end
    
    @files.each do |pair|
      threads << Thread.new {
        output = Search2Tab.new(PepXML.new(pair[0], pair[1], @proteins, @decoyProteins)).convert
        exec("percolator -j #{output}.tab > #{output}.psms") if fork == nil
        outputs << "#{output}.psms"
      }
    end
    
    threads.each {|thread| thread.join}
    waitForAllProcesses
    
    outputs
  end
end
