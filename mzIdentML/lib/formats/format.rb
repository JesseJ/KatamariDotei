require "spect_id_result"
require 'nokogiri'
require 'set'

# A base class for other file formats. Other formats are meant to inherit from this class, thus Format is basically useless by itself.
# Contains some methods that are applicable to all formats.
# Classes that inherit from Format are used as the means of obtaining information from a file to be used in Search2mzIdentML.
#
# @author Jesse Jashinsky (Aug 2010)
class Format
  # @param [String] file the location of the input file
  # @param [String] database the location of the FASTA database that was used by the search engine
  def initialize(file, database)
    puts "\nPreparing..."
    
    @file = file
    @database = database
    
    check_input
    
    @missedMappings = Set.new
    @obo = {}
    yml = YAML.load_file File.expand_path(File.dirname(__FILE__) + "/../oboe.yaml")
    yml.each {|x| @obo[x[:pepxml_name]] = [x[:id], x[:mzid_name]]}
  end
  
  # @return [String] the file
  def file
    ""
  end
  
  # @return [String] a string that says "pepxml"
  def type
    "invalid"
  end
  
  # @return [String] the database
  def database
    ""
  end
  
  # @return [String] the name of the search engine
  def searchEngine
    ""
  end
  
  # @return [String] the date in the file
  def date
    ""
  end
  
  # @return [Number] the threshold value
  def threshold
    0
  end
	
  # @return [Array(String, String, String)] all the proteins
  def proteins
    []
  end
  
  # @return [Array(String, String)] all the peptides
  def peptides
    []
  end
  
  # @return [String] the name of the search database that was used
  def databaseName
    ""
  end
  
  # @return [Array(SpectIdResult)] the results of the search engine
  def results
    []
  end
  
  # @return [Integer] the number of database sequences
  def numberOfSequences
    0
  end
  
  # Converts calc_neutral_pep_mass to calculatedMassToCharge
  #
  # @param [Float] mass the mass
  # @param [Float] charge the charge
  # @return [Float] the calculatedMassToCharge
  def calMass(mass, charge)
    (mass + (charge.to_f * 1.00727646677)) / charge
  end
  			
  # Converts calc_neutral_pep_mass to experimentalMassToCharge
  #
  # @param [Float] mass the mass
  # @param [Float] charge the charge
  # @param [Float] diff the diff value
  # @return [Float] the experimentalMassToCharge
  def experiMass(mass, charge, diff)
    ((mass + diff) + (charge.to_f * 1.00727646677)) / charge
  end
  
  # Displays warnings for any pepXML terms that didn't map to mzIdentML so that the user is aware of the missing data.
  def display_missed_mappings
    if !@missedMappings.empty?
      @missedMappings.each do |term|
        puts "WARNING: \"#{term}\" doesn't map to anything in oboe.yaml, and thus won't be displayed in the mzIdentML file."
      end
    end
  end
  
  # Determines the accession number for the given name.
  #
  # @param [String] name the original name of the paramater
  # @return [Aray(String, String)] the number and name
  def findAccession(name)
    if arr = @obo[name]
      arr
    else
      @missedMappings << name
      ["", ""]
    end
  end
	
  # Conforms score name to mzIdentML format. Will most likely need to be extended.
  #
  # @param [String] name the name of the score
  # @param [String] engine the name of the search engine
  def conformScoreName(name, engine)
    base = 
      case engine
        when "X! Tandem"
          "xtandem"
        when "MASCOT"
          "mascot"
        when "OMSSA"
          "OMSSA"
        when "Tide"
           "sequest"
        when "Phenyx"
          "Phenyx"
        when "SpectraST"
          "SpectraST"
      end
      
    [base, name].join(':')
  end
  
  
  private
  
  def check_input
    raise(ArgumentError, "Invalid input file") if !File.exist?(@file)
    raise(ArgumentError, "Invalid database input") if !File.exist?(@database)
  end
end
