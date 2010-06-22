require "#{$path}format.rb"
require 'nokogiri'

class PepXML < Format
  def initialize(target, decoy, database, revDatabase)
    super
  end
  
  #This method can likely be simplified
  def fileWithoutExtras
    parts = @target.split("/")
    parts = parts[parts.length-1].split("-")
    fileName = "#{$path}../data/" + parts[0] + parts[1][6..parts[1].length-1].chomp(".pep.xml")
    
    fileName
  end
    
  def target
    @target
  end
  
  def decoy
    @decoy
  end
  
  #Creates and returns a header for the tab file
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

  def matches
    parse if @matches == []
    
    @matches
  end
  
  
  private
  
  #Returns a Nokogiri object
  def nokogiriDoc(file)
    doc = Nokogiri::XML(IO.read("#{file}"))
        
    #Nokogiri won't parse out the information of an XML file that uses namespaces unless you add xmlns, and vice versa.
    @xmlns = "xmlns:" if doc.xpath("msms_pipeline_analysis").to_s.length == 0
      
    doc
  end
  
  #Parses out everyhting in the pepXML file
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
    #Required Stuff
    spect = query.xpath("./@spectrum").to_s.chomp(" ")    #X! Tandem has a space at the end that messes things up
    psm = "#{spect}.#{rank}" + "\t"                       #id = name.spectrum.spectrum.charge.rank
    psm += label + "\t"
    
    #Other stuff
    hit = query.xpath(".//#{@xmlns}search_hit[@hit_rank=\"#{rank}\"]")
    psm += spect.split(".")[3] + "\t"
    
    hit.xpath(".//#{@xmlns}search_score").each do |score|
      psm += score.xpath("./@value").to_s + "\t"
    end
    
    #Required Stuff
    pep = hit.xpath("./@peptide").to_s
    psm += pep + "\t"
    
    psm += proteins(pep, :target) if label == "1"
    psm += proteins(pep, :decoy) if label == "-1"
    
    #id <tab> label <tab> charge <tab> score1 <tab> ... <tab> scoreN <tab> peptide <tab> proteinId1 <tab> .. <tab> proteinIdM 
    psm
  end
end
