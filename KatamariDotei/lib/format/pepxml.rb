require "format/format.rb"
require 'nokogiri'

module PercolatorInput
  # A pepXML Format object.
  #
  # @author Jesse Jashinsky (Aug 2010)
  class PepXML < Format
    # @param [String] target the file location of the target pepXML
    # @param [String] decoy the file location of the decoy pepXML
    # @param [Hash] proteins a hash of peptides to proteins
    def initialize(target, decoy, proteins)
      super
    end
    
    # @return [String] file location without extension and target
    def fileWithoutExtras
      parts = @target.split("/")[-1].split("-")
      fileName = "#{$path}../data/percolator/" + parts[0] + parts[1][6..-1].chomp(".pep.xml")
      
      fileName
    end
    
    # @return [String] the target file location
    def target
      @target
    end
    
    # @return [String] the decoy file location
    def decoy
      @decoy
    end
    
    # Creates and returns a header for the tab file.
    #
    # @return [String] the header
    def header
      temp = ""
      result = "SpecId\tLabel\tCharge\t"
      
      nokogiriDoc(@target).xpath("//#{@xmlns}search_hit").each do |hit|
        temp = hit.xpath(".//#{@xmlns}search_score")
        break
      end
      
      temp.each do |score|
        result += score.xpath("./@name").to_s + "\t"
      end
      
      result += "Peptide\t" + "Proteins"
    end
    
    # @return [Array(String)] an array of spectral matches
    def matches
      parse if @matches == []
      
      @matches
    end
    
    
    private
    
    # @param [String] file the location of the pepXML file
    # @return [Nokogiri] a Nokogiri object
    def nokogiriDoc(file)
      doc = Nokogiri::XML(IO.read("#{file}"))
          
      #Nokogiri won't parse out the information of an XML file that uses namespaces unless you add xmlns, and vice versa.
      @xmlns = "xmlns:" if doc.xpath("msms_pipeline_analysis").to_s.length == 0
        
      doc
    end
    
    # Parses out everyhting in the pepXML file
    def parse
      #Target
      doc = nokogiriDoc(@target)
      
      doc.xpath("//#{@xmlns}spectrum_query").each do |query|
        count = query.xpath(".//#{@xmlns}search_hit").length
        1.upto(count) {|i| @matches << psm(query, "1", i)}
      end
      GC.start  # More memory can be salvaged by placing this before the end, but speed greatly declines.
      
      #Decoy
      doc = nokogiriDoc(@decoy)
      
      doc.xpath("//#{@xmlns}spectrum_query").each do |query|
        count = query.xpath(".//#{@xmlns}search_hit").length
        1.upto(count) {|i| @matches << psm(query, "-1", i)}
      end
      GC.start
    end
    
    # Parses the pepXML file and returns an PSM object (A line for the .tab file)
    #
    # @param [Nokogiri] query a Nokogiri object from a search query
    # @param [String] label a string of either a 1 or a -1
    # @param [Number] rank the rank of the search hit
    def psm(query, label, rank)
      #Required Stuff
      spect = query.xpath("./@spectrum").to_s.chomp(" ")    #X! Tandem has a space at the end that messes things up
      psm = []
      psm << "#{spect}.#{rank}"                             #id = name.spectrum.spectrum.charge.rank
      psm << label
      
      #Other stuff
      hit = query.xpath(".//#{@xmlns}search_hit[@hit_rank=\"#{rank}\"]")
      psm << spect[-1]
      
      hit.xpath(".//#{@xmlns}search_score").each do |score|
        psm << score.xpath("./@value").to_s
      end
      
      #Required Stuff
      pep = hit.xpath("./@peptide").to_s
      psm << pep
      
      psm << proteins(pep)
      
      #id <tab> label <tab> charge <tab> score1 <tab> ... <tab> scoreN <tab> peptide <tab> proteinId1 <tab> .. <tab> proteinIdM 
      psm.join("\t")
    end
  end
end