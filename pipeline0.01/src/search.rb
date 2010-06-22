require 'builder'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require "#{$path}tide_converter.rb"
require 'mechanize'

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
		puts "Running search engines...\n\n"
		
		threads = []
		
		threads << Thread.new {runOMSSA} if @opts[:omssa] == true
		threads << Thread.new {runTide} if @opts[:tide] == true
		threads << Thread.new {runTandem} if @opts[:xtandem] == true
		threads << Thread.new {runMascot} if @opts[:mascot] == true
		
		#Wait for all the processes and threads to finish before moving on
		threads.each {|thread| thread.join}
		waitForAllProcesses
    
    @outputFiles
  end
  
  def runTandem
    #Target search
    createTandemInput(false)
        
    pid1 = fork {exec("#{$path}../../tandem-linux/bin/tandem.exe #{$path}../data/targetTandemInput.xml")}
            
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
      file = File.new("#{$path}../data/targetTandemInput.xml", "w+")
    end
        
    xml = Builder::XmlMarkup.new(:target => file, :indent => 4)
    xml.instruct! :xml, :version => "1.0"
            
    notes = {'list path, default parameters' => "#{$path}../../tandem-linux/bin/default_input.xml",
             'list path, taxonomy information' => "#{$path}../../databases/taxonomy.xml",
             'spectrum, path' => "#{@file}.mgf",
             'protein, cleavage site' => "#{getTandemEnzyme}",
             'scoring, maximum missed cleavage sites' => 50}
        
    if decoy
      notes['protein, taxon'] = "#{@database}-r"
      notes['output, path'] = "#{@file}-decoy_tandem_#{@run}.xml"
    else
      notes['protein, taxon'] = "#{@database}"
      notes['output, path'] = "#{@file}-target_tandem_#{@run}.xml"
    end
                 
    xml.bioml do 
      notes.each do |label, path|
       xml.note(path, :type => "input", :label => label)
      end
    end
            
    file.close
  end
    
  def runOMSSA
    target = "#{@file}-target_omssa_#{@run}.pep.xml"
    decoy = "#{@file}-decoy_omssa_#{@run}.pep.xml"
		
    #Target search
    exec("#{$path}../../omssa/omssacl -fm #{@file}.mgf -op #{target} -e #{getOMSSAEnzyme} -d #{extractDatabase(@database)}") if fork == nil
		
    #Decoy search
    exec("#{$path}../../omssa/omssacl -fm #{@file}.mgf -op #{decoy} -e #{getOMSSAEnzyme} -d #{extractDatabase(@database + "-r")}") if fork == nil
		
    @outputFiles << [target, decoy]
  end
    
  def runTide
  	database = extractDatabase(@database)
   	databaseR = extractDatabase(@database + "-r")
    path = "#{$path}../../crux/tide/"
    tFile = "#{@file}-target_tide_#{@run}"
    dFile = "#{@file}-decoy_tide_#{@run}"
		
    pidF = fork {exec("#{path}tide-index --fasta #{database} --enzyme #{@enzyme} --digestion full-digest")}
    pidR = fork {exec("#{path}tide-index --fasta #{databaseR} --enzyme #{@enzyme} --digestion full-digest")}
		
		#tide-import-spectra
		pidB = fork {exec("#{path}tide-import-spectra --in #{@file}.ms2 -out #{@file}-tide.spectrumrecords")}
		
		#Target tide-search
		waitForProcess(pidF)
		waitForProcess(pidB)
		pidF = fork {exec("#{path}tide-search --proteins #{database}.protix --peptides #{database}.pepix --spectra #{@file}-tide.spectrumrecords > #{tFile}.results")}
		
		#Decoy tide-search
		waitForProcess(pidR)
		waitForProcess(pidB)
		pidR = fork {exec("#{path}tide-search --proteins #{databaseR}.protix --peptides #{databaseR}.pepix --spectra #{@file}-tide.spectrumrecords > #{dFile}.results")}
		
		waitForProcess(pidF)
		waitForProcess(pidR)
		
		#Convert
		TideConverter.new(tFile, database, @enzyme).convert
		TideConverter.new(dFile, databaseR, @enzyme).convert
		
		@outputFiles << ["#{tFile}.pep.xml", "#{dFile}.pep.xml"]
  end
	
  def runMascot
    yml = YAML.load_file "#{$path}../../mascot/mascot.yaml"
    searchURI = "search_form.pl?FORMVER=2&SEARCH=MIS"
    threads = []
    
    #Target search     
    targetAgent = Mechanize.new {|agent| agent.user_agent_alias = 'Linux Firefox'}
    
    targetAgent.get(yml["URL"] + searchURI) do |page|
      threads << Thread.new {automateMascot(targetAgent, page, yml, :target)}
    end
    
    #Decoy search
    decoyAgent = Mechanize.new {|agent| agent.user_agent_alias = 'Linux Firefox'}
    
    decoyAgent.get(yml["URL"] + searchURI) do |page|
      threads << Thread.new {automateMascot(decoyAgent, page, yml, :decoy)}
    end
    
    threads.each {|thread| thread.join}
    @outputFiles << ["#{@file}-target_mascot_#{@run}.pep.xml", "#{@file}-decoy_mascot_#{@run}.pep.xml"]
  end
  
  #Not the best name. Just a factored-out method runMascot.
  def automateMascot(a, page, yml, type)
    form = page.form('mainSearch')
    form.USERNAME = yml["USERNAME"]
    form.USEREMAIL = yml["USEREMAIL"]
    form.DB = getMascotDatabaseName(@database) if type == :target
    form.DB = getMascotDatabaseName(@database + "-r") if type == :decoy
    form.TAXONOMY = yml["TAXONOMY"]
    form.CLE = yml["CLE"]
    form.PFA = yml["PFA"]
    form.MODS = yml["MODS"]
    form.IT_MODS = yml["IT_MODS"]
    form.QUANTITATION = yml["QUANTITATION"]
    form.TOL = yml["TOL"]
    form.TOLU = yml["TOLU"]
    form.PEP_ISOTOPE_ERROR = yml["PEP_ISOTOPE_ERROR"]
    form.ITOL = yml["ITOL"]
    form.ITOLU = yml["ITOLU"]
    form.CHARGE = yml["CHARGE"]
    form.radiobuttons_with(:name => 'MASS')[yml["MASS"].to_i].check
    form.FORMAT = yml["FORMAT"]
    form.PRECURSOR = yml["PRECURSOR"]
    form.INSTRUMENT = yml["INSTRUMENT"]
    #form.checkbox_with(:name => 'DECOY').check if type == :decoy          #Not sure if this is needed
    form.checkbox_with(:name => 'ERRORTOLERANT').check if yml["ERRORTOLERANT"] == "true"
    form.REPORT = yml["REPORT"]
    form.file_uploads.first.file_name = @file + ".mgf"
    
    puts "Running #{type} Mascot..."
    page = a.submit(form, form.buttons.first)
    uri = page.links[0].uri.to_s.split("=")
    mascotFile = uri[uri.length-1].gsub("/", "%2F")
    page = page.links[0].click
    
    puts "Transforming #{type} Mascot output..."
    #Doesn't work for some reason
#    form = page.form('Re-format')
#    form.REPTYPE = "export"
#    page = a.submit(form, form.buttons.first)
    
    #An ugly solution
    link = yml["URL"] + "export_dat_2.pl?file=#{mascotFile}&REPTYPE=export&_sigthreshold=0.05&REPORT=AUTO&_server_mudpit_switch=99999999&_ignoreionsscorebelow=0&_showsubsets=0&_showpopups=TRUE&_sortunassigned=scoredown&_requireboldred=0"
    
    a.get(link) do |export_page|
      form = export_page.form('Re-format')
      form.field_with(:name => 'export_format').options[2].select
      page = a.submit(form, form.buttons[1])
      File.open("#{@file}-target_mascot_#{@run}.pep.xml", 'w') {|f| f.write(page.body)} if type == :target
      File.open("#{@file}-decoy_mascot_#{@run}.pep.xml", 'w') {|f| f.write(page.body)} if type == :decoy
    end
  end

	def runSpectraST
		#Target search
		pid = fork {exec("/usr/local/src/tpp-4.3.1/build/linux/spectrast -cN #{$path}../data/#{@fileName} #{@file}.ms2")}
		
		waitForProcess(pid)
		exec("/usr/local/src/tpp-4.3.1/build/linux/spectrast -sD #{@database} -sL #{$path}../data/#{@fileName}.splib #{@file}.mzXML") if fork == nil
	end
    
  def convertTandemOutput
    #Convert to pepXML format
    file1 = "#{@file}-target_tandem_#{@run}.xml"
    file2 = "#{@file}-decoy_tandem_#{@run}.xml"
    pepFile1 = file1.chomp(".xml") + ".pep.xml"
    pepFile2 = file2.chomp(".xml") + ".pep.xml"
    @outputFiles << [pepFile1, pepFile2]
        
    exec("/usr/local/src/tpp-4.3.1/build/linux/Tandem2XML #{file1} #{pepFile1}") if fork == nil
    exec("/usr/local/src/tpp-4.3.1/build/linux/Tandem2XML #{file2} #{pepFile2}") if fork == nil
  end
    
  def getOMSSAEnzyme
    Nokogiri::XML(IO.read("#{$path}../../omssa/OMSSA.xsd")).xpath("//xs:enumeration[@value=\"#{@enzyme}\"]/@ncbi:intvalue").to_s
  end
	
	def getTandemEnzyme
		Nokogiri::XML(IO.read("#{$path}../../tandem-linux/enzymes.xml")).xpath("//enzyme[@name=\"#{@enzyme}\"]/@symbol").to_s
	end
	
  def getMascotDatabaseName(id)
    Nokogiri::XML(IO.read("#{$path}../../mascot/database-Mascot.xml")).xpath("//DB[@ID=\"#{id}\"]/@mascot_name").to_s
  end
end
