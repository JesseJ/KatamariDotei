require "#{$path}format.rb"
require 'nokogiri'

class PepXML < Format
  def initialize(target, decoy)
    super
  end
  
  #This method can likely be simplified
  def file
    parts = @target.split("/")
    parts = parts[parts.length-1].split("-")
    fileName = "#{$path}../data/" + parts[0] + parts[1][7..parts[1].length-1].chomp(".pep.xml")
    
    fileName
  end
    
  def target
    @target
  end
  
  def decoy
    @decoy
  end
  
  def matches
    parse if @matches == []
    
    @matches
  end
  
  
  private
  
  def nokogiriDoc(file)
    doc = Nokogiri::XML(IO.read("#{file}"))
        
    #Nokogiri won't parse out the information of an XML file that uses namespaces unless you add xmlns, and vice versa.
    @xmlns = "xmlns:" if doc.xpath("msms_pipeline_analysis").to_s.length == 0
      
    doc
  end
  
  def parse
    #Target
    doc = nokogiriDoc(@target)
    
    doc.xpath("//#{@xmlns}spectrum_query").each do |query|
      count = query.xpath(".//#{@xmlns}search_hit").length
      1.upto(count) {|i| @matches << psm(query, "1", i)}
    end
    
    #Decoy
    doc = nokogiriDoc(@decoy)
    
    doc.xpath("//#{@xmlns}spectrum_query").each do |query|
      count = query.xpath(".//#{@xmlns}search_hit").length
      1.upto(count) {|i| @matches << psm(query, "-1", i)}
    end
  end
  
  #Parses the pepXML file and returns an PSM object (A line for the .tab file)
  def psm(query, label, rank)
    spect = query.xpath("./@spectrum").to_s.chomp(" ")    #X! Tandem has a space at the end that messes things up
    psm = "#{spect}.#{rank}" + "\t"
    psm += label + "\t"       #id = name.spectrum.spectrum.charge.rank
    
    #Other stuff
    hit = query.xpath(".//#{@xmlns}search_hit[@hit_rank=\"#{rank}\"]")
    psm += spect.split(".")[3] + "\t"
    
    hit.xpath(".//#{@xmlns}search_score").each do |score|
      psm += score.xpath("./@value").to_s + "\t"
    end
    
    psm += hit.xpath("./@peptide").to_s + "\t"
    
    hit.xpath("./@protein").each do |protein|
      psm += protein.to_s + "\t"
    end
    
    #id <tab> label <tab> charge <tab> score1 <tab> ... <tab> scoreN <tab> peptide <tab> proteinId1 <tab> .. <tab> proteinIdM 
    psm.chomp("\t")
  end
end
