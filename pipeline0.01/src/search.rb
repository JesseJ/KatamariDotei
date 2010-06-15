require 'builder'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require "#{$path}tide_converter.rb"
#require "#{$path}/ms-mascot/lib/ms/mascot/submit.rb"
include Process

#file == input file
#database == type of fasta database to use, e.g. "human"
#enzyme == the enzyme to use in the search, e.g. trypsin
#run == which run, or iteration, this is
#opts: All option values are either true or false.
class Search
	def initialize(file, database, enzyme, run, opts={})
		@opts = opts
		@run = run
		@enzyme = enzyme
		@database = database
		@file = file
        
		temp = file.split("/")
    @fileName = temp[temp.length - 1]
    @outputFiles = []
  end
    
	def run
		puts "\n----------------"
		puts "Running search engines..."
		
		threads = []
		
		threads << Thread.new {runOMSSA} if @opts[:omssa] == true
		threads << Thread.new {runTide} if @opts[:tide] == true
		threads << Thread.new {runTandem} if @opts[:xtandem] == true
		threads << Thread.new {runSpectraST} if @opts[:spectrast] == true
		
		#Wait for all the processes and threads to finish before moving on
		threads.each {|thread| thread.join}
		waitForAllProcesses
        
    @outputFiles
  end
    
  def runTandem
    #Forward search
    createTandemInput(false)
        
    pid1 = fork {exec("#{$path}../../tandem-linux/bin/tandem.exe #{$path}../data/forwardTandemInput.xml")}
            
    #Decoy search
		createTandemInput(true)
        
		pid2 = fork {exec("#{$path}../../tandem-linux/bin/tandem.exe #{$path}../data/decoyTandemInput.xml")}
    waitForProcess(pid1)
    waitForProcess(pid2)
		
		convertTandemOutput
  end
    
  #This is what I made before learning nokogiri. I could use nokogiri instead, but this is less code.
  def createTandemInput(decoy)
    if decoy
      file = File.new("#{$path}../data/decoyTandemInput.xml", "w+")
    else
      file = File.new("#{$path}../data/forwardTandemInput.xml", "w+")
    end
        
    xml = Builder::XmlMarkup.new(:target => file, :indent => 4)
    xml.instruct! :xml, :version => "1.0"
            
    notes = {'list path, default parameters' => "#{$path}../../tandem-linux/bin/default_input.xml",
             'list path, taxonomy information' => "#{$path}../data/taxonomy.xml",
             'spectrum, path' => "#{@file}.mgf",
             'protein, cleavage site' => "#{getTandemEnzyme}",
             'scoring, maximum missed cleavage sites' => 50}
        
    if decoy
      notes['protein, taxon'] = "#{@database}-r"
      notes['output, path'] = "#{@file}-decoy_tandem_#{@run}.xml"
    else
      notes['protein, taxon'] = "#{@database}"
      notes['output, path'] = "#{@file}-forward_tandem_#{@run}.xml"
    end
                 
    xml.bioml do 
      notes.each do |label, path|
       xml.note(path, :type => "input", :label => label)
      end
    end
            
    file.close
  end
    
	def runOMSSA
		forward = "#{@file}-forward_omssa_#{@run}.pep.xml"
		decoy = "#{@file}-decoy_omssa_#{@run}.pep.xml"
		
		#Forward search
		exec("#{$path}../../omssa/omssacl -fm #{@file}.mgf -op #{forward} -e #{getOMSSAEnzyme} -d #{extractDatabase(@database)}") if fork == nil
		
		#Decoy search
		exec("#{$path}../../omssa/omssacl -fm #{@file}.mgf -op #{decoy} -e #{getOMSSAEnzyme} -d #{extractDatabase(@database + "-r")}") if fork == nil
		
		@outputFiles << [forward, decoy]
	end
    
  def runTide
  	database = extractDatabase(@database)
   	databaseR = extractDatabase(@database + "-r")
    path = "#{$path}../../crux/tide/"
    fFile = "#{@file}-forward_tide_#{@run}"
    dFile = "#{@file}-decoy_tide_#{@run}"
		
    pidF = fork {exec("#{path}tide-index --fasta #{database} --enzyme #{@enzyme} --digestion full-digest")}
    pidR = fork {exec("#{path}tide-index --fasta #{databaseR} --enzyme #{@enzyme} --digestion full-digest")}
		
		#tide-import-spectra
		pidB = fork {exec("#{path}tide-import-spectra --in #{@file}.ms2 -out #{@file}-forward_tide.spectrumrecords")}
		
		#Forward tide-search
		waitForProcess(pidF)
		waitForProcess(pidB)
		pidF = fork {exec("#{path}tide-search --proteins #{database}.protix --peptides #{database}.pepix --spectra #{@file}-forward_tide.spectrumrecords > #{fFile}.results")}
		
		#Decoy tide-search
		waitForProcess(pidR)
		waitForProcess(pidB)
		pidR = fork {exec("#{path}tide-search --proteins #{databaseR}.protix --peptides #{database}.pepix --spectra #{@file}-decoy_tide.spectrumrecords > #{dFile}.results")}
		
		waitForProcess(pidF)
		waitForProcess(pidR)
		
		#Convert
		TideConverter.new(fFile, database, @enzyme).convert
		TideConverter.new(dFile, databaseR, @enzyme).convert
		
		@outputFiles << ["#{fFile}.pep.xml", "#{dFile}.pep.xml"]
  end
	
	def runSpectraST
		#Forward search
		pid = fork {exec("/usr/local/src/tpp-4.3.1/build/linux/spectrast -cN #{$path}../data/#{@fileName} #{@file}.ms2")}
		
		waitForProcess(pid)
		exec("/usr/local/src/tpp-4.3.1/build/linux/spectrast -sD #{@database} -sL #{$path}../data/#{@fileName}.splib #{@file}.mzXML") if fork == nil
	end
    
  def convertTandemOutput
    #Convert to pepXML format
    file1 = "#{@file}-forward_tandem_#{@run}.xml"
    file2 = "#{@file}-decoy_tandem_#{@run}.xml"
    pepFile1 = file1.chomp(".xml") + ".pep.xml"
    pepFile2 = file2.chomp(".xml") + ".pep.xml"
    @outputFiles << [pepFile1, pepFile2]
        
    exec("/usr/local/src/tpp-4.3.1/build/linux/Tandem2XML #{file1} #{pepFile1}") if fork == nil
    exec("/usr/local/src/tpp-4.3.1/build/linux/Tandem2XML #{file2} #{pepFile2}") if fork == nil
  end
    
  def extractDatabase(database)
    doc = Nokogiri::XML(IO.read("#{$path}../data/taxonomy.xml"))
    return doc.xpath("//taxon[@label=\"#{database}\"]//file/@URL")
  end
    
  def getOMSSAEnzyme
    doc = Nokogiri::XML(IO.read("#{$path}../../omssa/OMSSA.xsd"))
    return doc.xpath("//xs:enumeration[@value=\"#{@enzyme}\"]/@ncbi:intvalue")
  end
	
	def getTandemEnzyme
		doc = Nokogiri::XML(IO.read("#{$path}../../tandem-linux/enzymes.xml"))
		return doc.xpath("//enzyme[@name=\"#{@enzyme}\"]/@symbol")
	end
end
