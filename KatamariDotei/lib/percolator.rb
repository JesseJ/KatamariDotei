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
    
    # The format of the following two functions were chosen to rersult in the fastest processing time.
    # w/o threads: 47.234498187s
    # w/ threads: 39.02959521s - 50.158238575s (A time above 47, like 50, seems rare)
    threads << Thread.new {load_target(':')}
    threads << Thread.new {load_decoy(':')}
    
    threads.each {|thread| thread.join}
    GC.start
    
    options = config_value("//Percolator/@commandLine")
    
    
    @files.each do |pair|
      threads << Thread.new {  #If fork keeps failing at this point because of not enough memory, then get rid of the threading here.
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
    
    buffer = nil  #Fork will fail if there's not enough memory. This is an attempt to help.
  end
  
  def load_decoy(delim)
    buffer = File.readlines(extractDatabase(@type + "-r").chomp("fasta.reverse") + "yml")
    
    buffer.each do |line|
      index = line.index(delim)
      @decoyProteins[line[0,index]] = line[index+2,line.length-1]
    end
    
    buffer = nil
  end
end
