require "#{File.dirname($0)}/spect_id_result.rb"
require 'nokogiri'
require 'set'

# A base class for other file formats. Other formats are meant to inherit from this class, thus Format is basically useless by itself.
# Contains some methods that are applicable to all formats.
# Classes that inherit from Format are used as the means of obtaining information from a file to be used in Search2mzIdentML.
class Format
  # file == a string containing the search engine output file location
  # database == a string containing the FASTA database that was used by the search engine
  def initialize(file, database)
    puts "\nPreparing..."
    
    @file = file
    @database = database
    
    check_input
    
    @missedMappings = Set.new
    @obo = {}
    yml = YAML.load_file "#{File.dirname($0)}/oboe.yaml"
    yml.each {|x| @obo[x[:pepxml_name]] = [x[:id], x[:mzid_name]]}
  end
  
  def file
    ""
  end
  
  def type
    "invalid"
  end
  
  def database
    ""
  end
  
  # Retrieves the name of the search engine
  def searchEngine
    ""
  end
  
  # Retrieves the date in the file
  def date
    ""
  end
  
  # Retrieves the threshold value
  def threshold
    0
  end
	
  # Retrieves all the proteins
  def proteins
    []
  end
  
  # Retrieves all the peptides
  def peptides
    []
  end
  
  # Retrieves the name of the search database that was used
  def databaseName
    ""
  end
  
  # Retrieves the results of the search engine
  def results
    []
  end
  
  # Retrieves the number of database sequences
  def numberOfSequences
    0
  end
  
  # Converts calc_neutral_pep_mass to calculatedMassToCharge
  def calMass(mass, charge)
    (mass + (charge.to_f * 1.00727646677)) / charge
  end
  			
  # Converts calc_neutral_pep_mass to experimentalMassToCharge
  def experiMass(mass, charge, diff)
    ((mass + diff) + (charge.to_f * 1.00727646677)) / charge
  end
  
  # Displays warnings for any pepXML terms that didn't map to mzIdentML
  def display_missed_mappings
    if !@missedMappings.empty?
      @missedMappings.each do |term|
        puts "WARNING: \"#{term}\" doesn't map to anything in oboe.yaml, and thus won't be displayed in the mzIdentML file."
      end
    end
  end
  
  # Determines the accession number for the given name.
  def findAccession(name)
    if arr = @obo[name]
      arr
    else
      @missedMappings << name
      ["", ""]
    end
  end
	
  # Conforms score name to mzIdentML format. Will most likely need to be extended.
  def conformScoreName(name, engine)
    base = 
      case engine
        when "X! Tandem"
          "xtandem"
        when "MASCOT"
          "mascot"
        when "OMSSA"
          "OMSSA"
      end
      
    [base, name].join(':')
  end
  
  
  private
  
  def check_input
    raise(ArgumentError, "Invalid input file") if !File.exist?(@file)
    raise(ArgumentError, "Invalid database input") if !File.exist?(@database)
  end
end
