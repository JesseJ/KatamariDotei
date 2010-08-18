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
    
    outputs = []
    threads = []
    tab_files = []
    
    # The format of the following function was chosen to rersult in the fastest processing time.
    proteins = load_target(':')
    GC.start
    
    p "data loaded"
    @files.each do |pair|
      tab_files << Search2Tab.new(PercolatorInput::PepXML.new(pair[0], pair[1], proteins)).convert
      GC.start
    end
    
    p "files created"
    options = config_value("//Percolator/@commandLine")
    
    tab_files.each do |file|
      system("percolator #{options} -j #{file}.tab > #{file}.psms")
      outputs << "#{file}.psms"
    end
    
    outputs
  end
  
  # returns a hash of peptides to proteins
  def load_target(delim)
    proteins = {}
    buffer = File.readlines(extractDatabase(@type).chomp("fasta") + "yml")
    
    buffer.each do |line|
      index = line.index(delim)
      proteins[line[0,index]] = line[index+2,line.length-1]
    end
    
    buffer = nil  #Fork will fail if there's not enough memory. This is an attempt to help.
    proteins
  end
end
