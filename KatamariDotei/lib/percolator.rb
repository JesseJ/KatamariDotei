require "format/search2tab"
require "helper_methods"

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
    
    t = Time.now
    
    
   threads << Thread.new {load_target(':')}
   threads << Thread.new {load_decoy(':')}
    
    threads.each {|thread| thread.join}
    p Time.now - t
    options = config_value("//Percolator/@commandLine")
    
    @files.each do |pair|
      threads << Thread.new {
        output = Search2Tab.new(PercolatorInput::PepXML.new(pair[0], pair[1], @proteins, @decoyProteins)).convert
        exec("percolator #{options} -j #{output}.tab > #{output}.psms") if fork == nil
        outputs << "#{output}.psms"
      }
    end
    
    threads.each {|thread| thread.join}
    waitForAllProcesses
    
    outputs
  end
  
  def load_target(delim)
    buffer = File.readlines(extractDatabase(@type).chomp("fasta") + "yml")
    
    buffer.each do |line|
      index = line.index(delim)
      @proteins[line[0,index]] = line[index+2,line.length-1]
    end
  end
  
  def load_decoy(delim)
    buffer = File.readlines(extractDatabase(@type + "-r").chomp("fasta.reverse") + "yml")
    
    buffer.each do |line|
      index = line.index(delim)
      @decoyProteins[line[0,index]] = line[index+2,line.length-1]
    end
  end
end
#w/o threads: 47.234498187
#w/ threads: 39.02959521 - 50.158238575 (A time above 47, like 50, seems rare)