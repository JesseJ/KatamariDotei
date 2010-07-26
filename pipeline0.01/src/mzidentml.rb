require "#{$path}format.rb"
require 'nokogiri'

# An mzIdentML Format object.
class MzIdentML < Format
  # target == A string containing the file location of the target pepXML
  # decoy == A string containing the file location of the decoy pepXML
  # database == A hash of target {peptide => proteins}
  # revDatabase == A hash of decoy {peptide => proteins}
  def initialize(target, decoy, database, revDatabase)
    super
    @fileName = ""
  end
  
  # This method can likely be simplified
  def fileWithoutExtras
    if @fileName == ""
      parts = @target.split("/")[-1].split("-")
      @fileName = "#{$path}../data/percolator/" + parts[0] + parts[1][6..parts[1].length-1].chomp(File.extname(@target))
      @peptides = {}
    end
    
    @fileName
  end
    
  def target
    @target
  end
  
  def decoy
    @decoy
  end
  
  # Creates and returns a header for the tab file.
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

  def matches
    parse if @matches == []
    
    @matches
  end
  
  
  private
  
  # Returns a Nokogiri object
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
  
  # Parses the pepXML file and returns an PSM object (A line for the .tab file)
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
    
    psm += proteins(pep, :target) if label == "1"
    psm += proteins(pep, :decoy) if label == "-1"
    
    #id <tab> label <tab> charge <tab> score1 <tab> ... <tab> scoreN <tab> peptide <tab> proteinId1 <tab> .. <tab> proteinIdM 
    psm
  end
  
  # Loads the peptides from the mzIdentML file into the peptides hash.
  def load_peptides(doc)
    @peptides = {}
    doc.xpath("//xmlns:Peptide").each do |peptide|
      @peptides[peptide.xpath("./@id").to_s] = peptide.xpath(".//xmlns:peptideSequence").text
    end
  end
end
