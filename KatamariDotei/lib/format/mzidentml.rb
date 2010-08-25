require "format/format.rb"
require 'nokogiri'

module PercolatorInput
  # An mzIdentML Format object.
  #
  # @author Jesse Jashinsky (Aug 2010)
  class MzIdentML < Format
    # @param [String] target the file location of the target mzIdentML
    # @param [String] decoy the file location of the decoy mzIdentML
    # @param [Hash] proteins a hash of peptides to proteins
    def initialize(target, decoy, proteins)
      super
      @fileName = ""
    end
    
    # @return [String] file location without extension and target
    def fileWithoutExtras
      if @fileName == ""
        parts = @target.split("/")[-1].split("-")
        @fileName = "#{$path}../data/percolator/" + parts[0] + parts[1][6..-1].chomp(File.extname(@target))
        @peptides = {}
      end
      
      @fileName
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
      
      nokogiriDoc(@target).xpath("//xmlns:SpectrumIdentificationItem").each do |hit|
        temp = hit.xpath(".//xmlns:cvParam")
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
      Nokogiri::XML(IO.read("#{file}"))
    end
    
    # Parses out everyhting in the mzIdentML file
    def parse
      #Target
      doc = nokogiriDoc(@target)
      load_peptides(doc)
      
      doc.xpath("//xmlns:SpectrumIdentificationResult").each do |result|
        count = result.xpath(".//xmlns:SpectrumIdentificationItem").length
        listNum = result.xpath("./@id").to_s.split("_")[-1]
        1.upto(count) {|i| @matches << psm(doc, result, "1", listNum, i)}
      end
      
      #Decoy
      doc = nokogiriDoc(@decoy)
      load_peptides(doc)
      
      doc.xpath("//xmlns:SpectrumIdentificationResult").each do |result|
        count = result.xpath(".//xmlns:SpectrumIdentificationItem").length
        listNum = result.xpath("./@id").to_s.split("_")[-1]
        1.upto(count) {|i| @matches << psm(doc, result, "-1", listNum, i)}
      end
    end
    
    # Parses the mzIdentML file and returns an PSM object (A line for the .tab file)
    #
    # @param [Nokogiri] doc the whole doc
    # @param [Nokogiri] query a Nokogiri object from a search query
    # @param [String] label a string of either a 1 or a -1
    # @param [String] listNum can't seem to remmeber what this is
    # @param [Number] rank the rank of the search hit
    def psm(doc, query, label, listNum, rank)
      #Required Stuff
      hit = query.xpath(".//xmlns:SpectrumIdentificationItem[@id=\"SII_#{listNum}_#{rank}\"]")
      charge = hit.xpath("./@chargeState").to_s
      spect = query.xpath("./@spectrumID").to_s.split("=")[1]
      psm = "#{fileWithoutExtras.split("/")[-1]}.#{spect}.#{spect}.#{charge}.#{rank}" + "\t"
      psm += label + "\t"
      
      #Other stuff
      psm += charge + "\t"
      
      hit.xpath(".//xmlns:cvParam").each do |score|
        psm += score.xpath("./@value").to_s + "\t"
      end
      
      #Required Stuff
      pep = @peptides[hit.xpath("./@Peptide_ref").to_s]
      psm += pep + "\t"
      
      psm += proteins(pep)
      
      #id <tab> label <tab> charge <tab> score1 <tab> ... <tab> scoreN <tab> peptide <tab> proteinId1 <tab> .. <tab> proteinIdM 
      psm
    end
    
    # Loads the peptides from the mzIdentML file into the peptides hash.
    #
    # @param [Nokogiri] doc the whole doc
    def load_peptides(doc)
      @peptides = {}
      doc.xpath("//xmlns:Peptide").each do |peptide|
        @peptides[peptide.xpath("./@id").to_s] = peptide.xpath(".//xmlns:peptideSequence").text
      end
    end
  end
end