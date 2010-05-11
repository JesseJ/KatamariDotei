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
            runOmssa
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
        file = File.new("#{$vpath}data/forwardTandemInput.xml", "w+")
            
        xml = Builder::XmlMarkup.new(:target => file, :indent => 4)
        xml.instruct! :xml, :version => "1.0"
            
        notes = {'list path, default parameters' => "#{$path}tandem-win32-10-01-01-4/bin/default_input.xml",
                 'list path, taxonomy information' => "#{$vpath}data/taxonomy.xml",
                 'protein, taxon' => @database,
                 'spectrum, path' => "#{@file}",
                 'output, path' => "#{@fileName}-forward_tandem_output.xml"}
            
        xml.bioml do 
            notes.each do |label, path|
                xml.note(path, :type => "input", :label => label)
            end
        end
            
        file.close
            
        if fork == nil
            exec("wine #{$path}tandem-win32-10-01-01-4/bin/tandem.exe #{$vpath}data/forwardTandemInput.xml")
        end
            
        #Decoy search
        file = File.new("#{$vpath}data/decoyTandemInput.xml", "w+")
            
        xml = Builder::XmlMarkup.new(:target => file, :indent => 4)
        xml.instruct! :xml, :version => "1.0"
            
        notes = {'list path, default parameters' => "#{$path}tandem-win32-10-01-01-4/bin/default_input.xml",
                 'list path, taxonomy information' => "#{$vpath}data/taxonomy.xml",
                 'protein, taxon' => "#{@database}-r",
                 'spectrum, path' => "#{@file}",
                 'output, path' => "#{@fileName}-decoy_tandem_output.xml"}
            
        xml.bioml do 
            notes.each do |label, path|
                xml.note(path, :type => "input", :label => label)
            end
        end
            
        file.close
            
        if fork == nil
            exec("wine #{$path}tandem-win32-10-01-01-4/bin/tandem.exe #{$vpath}data/decoyTandemInput.xml")
        end
    end
    
    def runOmssa
        #Forward search
        exec("omssacl -fm #{@file} -op #{@fileName}-forward_omssa_output.pep.xml -d #{$path}ipi/ipi.HUMAN.v3.72.fasta") if fork == nil
        
        #Decoy search
        exec("omssacl -fm #{@file} -op #{@fileName}-decoy_omssa_output.pep.xml -d #{$path}ipi/reverse/ipi.HUMAN.v3.72.fasta.reverse") if fork == nil
        
        @outputFiles << ["#{@fileName}-forward_omssa_output.pep.xml", "#{@fileName}-decoy_omssa_output.pep.xml"]
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
        oldFile1 = Dir["#{mgFile}-forward_tandem_output.*.xml"].first
        size = "#{mgFile}-forward_tandem_output".length
        newFile1 = oldFile1[0,size] + ".xml"
        FileUtils.mv(oldFile1, newFile1)
            
        #Decoy output
        mgFile = "#{@file}".chomp(".mgf")
        oldFile2 = Dir["#{mgFile}-decoy_tandem_output.*.xml"].first
        size = "#{mgFile}-decoy_tandem_output".length
        newFile2 = oldFile2[0,size] + ".xml"
        FileUtils.mv(oldFile2, newFile2)
        
        #Convert to pepXML format
        pepFile1 = newFile1.chomp(".xml") + ".pep.xml"
        pepFile2 = newFile2.chomp(".xml") + ".pep.xml"
        @outputFiles << [pepFile1, pepFile2]
        
        exec("wine Tandem2XML #{newFile1} #{pepFile1}") if fork == nil
        exec("wine Tandem2XML #{newFile2} #{pepFile2}") if fork == nil
    end
    
    def extractDatabase
        doc = Nokogiri::XML(File.open("#{$vpath}data/taxonomy.xml"))
        return doc.xpath("//taxon[@label=\"#{@database}\"]//file/@URL")
    end
end