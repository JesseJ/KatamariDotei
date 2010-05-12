require 'builder'
require 'rubygems'
require 'fileutils'
require 'nokogiri'
require "#{$path}ms-fasta/lib/ms/fasta.rb"

#file == input file
#database == type of fasta database to use, e.g. "human"
#enzyme == the enzyme to use in the search
#run == which run, or iteration, this is
# options (All options's default to true):
#     :omssa =>   true | false
#     :xtandem => true | false
#     :crux =>    true | false
#     :sequest => true | false
#     :mascot =>  true | false
class Search
    def initialize(file, database, enzyme, run, opts={})
        @opts = opts
        @run = run
        @enzyme = enzyme
        @database = database
        @file = file
        @fileName = @file.chomp(".mgf")
        @outputFiles = []
    end
    
    def run
        puts "\n----------------"
        puts "Running search engines..."
        
        if @opts[:xtandem] == true
            runTandem
        end
        
        if @opts[:omssa] == true
            runOMSSA
        end
        
        if @opts[:crux] == true
            #exec("") if fork == nil
        end
        
        if @opts[:sequest] == true
            #exec("") if fork == nil
        end
        
        if @opts[:mascot] == true
            #exec("") if fork == nil
        end
        
        #Wait for all the processes to finish before moving on
        waitForEverything
        
        #Convert X!Tandem files
        if @opts[:xtandem] == true
            convertTandemOutput
            waitForEverything
        end
        
        @outputFiles
    end
    
    def runTandem
        #Forward search
        createTandemInput(false)
        
        exec("wine #{$path}tandem-win32-10-01-01-4/bin/tandem.exe #{$vpath}data/forwardTandemInput.xml") if fork == nil
            
        #Decoy search
        createTandemInput(true)
        
        exec("wine #{$path}tandem-win32-10-01-01-4/bin/tandem.exe #{$vpath}data/decoyTandemInput.xml") if fork == nil
    end
    
    def createTandemInput(decoy)
        if decoy
            file = File.new("#{$vpath}data/decoyTandemInput.xml", "w+")
        else
            file = File.new("#{$vpath}data/forwardTandemInput.xml", "w+")
        end
            
        xml = Builder::XmlMarkup.new(:target => file, :indent => 4)
        xml.instruct! :xml, :version => "1.0"
            
        notes = {'list path, default parameters' => "#{$path}tandem-win32-10-01-01-4/bin/default_input.xml",
                 'list path, taxonomy information' => "#{$vpath}data/taxonomy.xml",
                 'spectrum, path' => "#{@file}",
                 'protein, cleavage site' => "#{getTandemEnzyme}",
                 'scoring, maximum missed cleavage sites' => 50}
        
        if decoy
            notes['protein, taxon'] = "#{@database}-r"
            notes['output, path'] = "#{@fileName}-decoy_tandem_output_#{@run}.xml"
        else
            notes['protein, taxon'] = "#{@database}"
            notes['output, path'] = "#{@fileName}-forward_tandem_output_#{@run}.xml"
        end
                 
        xml.bioml do 
            notes.each do |label, path|
                xml.note(path, :type => "input", :label => label)
            end
        end
            
        file.close
    end
    
    def runOMSSA
        forward = "#{@fileName}-forward_omssa_output_#{@run}.pep.xml"
        decoy = "#{@fileName}-decoy_omssa_output_#{@run}.pep.xml"
        
        #Forward search
        exec("omssacl -fm #{@file} -op #{forward} -e #{getOMSSAEnzyme} -d #{extractDatabase(@database)}") if fork == nil
        
        #Decoy search
        exec("omssacl -fm #{@file} -op #{decoy} -e #{getOMSSAEnzyme} -d #{extractDatabase(@database + "-r")}") if fork == nil
        
        @outputFiles << [forward, decoy]
    end
    
    def waitForEverything
        begin
            Process.wait while true
        
        rescue SystemCallError
            #No need to do anything here, just go
        end
    end
    
    def convertTandemOutput
        #Forward output
        mgFile = "#{@file}".chomp(".mgf")
        oldFile1 = Dir["#{mgFile}-forward_tandem_output_#{@run}.*.xml"].first
        size = "#{mgFile}-forward_tandem_output_#{@run}".length
        newFile1 = oldFile1[0,size] + ".xml"
        FileUtils.mv(oldFile1, newFile1)
            
        #Decoy output
        mgFile = "#{@file}".chomp(".mgf")
        oldFile2 = Dir["#{mgFile}-decoy_tandem_output_#{@run}.*.xml"].first
        size = "#{mgFile}-decoy_tandem_output_#{@run}".length
        newFile2 = oldFile2[0,size] + ".xml"
        FileUtils.mv(oldFile2, newFile2)
        
        #Convert to pepXML format
        pepFile1 = newFile1.chomp(".xml") + ".pep.xml"
        pepFile2 = newFile2.chomp(".xml") + ".pep.xml"
        @outputFiles << [pepFile1, pepFile2]
        
        exec("wine Tandem2XML #{newFile1} #{pepFile1}") if fork == nil
        exec("wine Tandem2XML #{newFile2} #{pepFile2}") if fork == nil
    end
    
    def extractDatabase(database)
        doc = Nokogiri::XML(IO.read("#{$vpath}data/taxonomy.xml"))
        return doc.xpath("//taxon[@label=\"#{database}\"]//file/@URL")
    end
    
    def getOMSSAEnzyme
        doc = Nokogiri::XML(IO.read("#{$path}omssa-2.1.7.linux/OMSSA.xsd"))
        return doc.xpath("//xs:enumeration[@value=\"#{@enzyme}\"]/@ncbi:intvalue")
    end
    
    def getTandemEnzyme
        doc = Nokogiri::XML(IO.read("#{$path}tandem-win32-10-01-01-4/enzymes.xml"))
        return doc.xpath("//enzyme[@name=\"#{@enzyme}\"]/@symbol")
    end
end