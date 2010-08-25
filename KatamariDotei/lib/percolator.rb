require "format/search2tab"
require "helper_methods"

# Runs Percolator
#
# @author Jesse Jashinsky (Aug 2010)
class Percolator
  # @param [Array(String, String)] files the output from Search.search
  # @param [String] type the type of database, e.g. "human" or "bovin"
  def initialize(files, type)
    @files = files
    @type = type
  end
  
  # Runs percolator on the given files
  #
  # @return [Array(String)] the psms files
  def run
    puts "\n--------------------------------"
    puts "Running Percolator...\n\n"
    
    outputs = []
    threads = []
    tab_files = []
    
    # The format of the following function was chosen to rersult in the fastest processing time.
    proteins = load_target(':')
    GC.start
    
    # Currently using pepXML instead of mzIdentML because pepXML has more scores to put in the tab files which may lead to more accurate Percolator output.
    @files.each do |pair|
      tab_files << Search2Tab.new(PercolatorInput::PepXML.new(pair[0], pair[1], proteins)).convert
      GC.start
    end
    
    options = config_value("//Percolator/@commandLine")
    
    tab_files.each do |file|
      system("percolator #{options} -j #{file}.tab > #{file}.psms")
      outputs << "#{file}.psms"
    end
    
    outputs
  end
  
  
  private
  
  # Loads the peptide centric database into a hash
  #
  # @param [String] delim the delimiter. It's passed in to increase speed.
  # @return [Hash] a hash of peptides to proteins
  def load_target(delim)
    proteins = {}
    buffer = File.readlines(extractDatabase(@type).chomp("fasta") + "yml")  #Loading into buffer is key to increasing speed.
    
    buffer.each do |line|
      index = line.index(delim)  #Creating two arrays instead of using split greatly increases speed.
      proteins[line[0,index]] = line[index+2,line.length-1]  #Using commas uses numbers, while using .. creates a range object.
    end
    
    buffer = nil  #Fork will fail if there's not enough memory. This is an attempt to help.
    proteins
  end
end
