require "#{File.dirname($0)}/spect_id_result.rb"
require 'nokogiri'

require 'pp'

#A base class for other file formats. Other formats are meant to inherit from this class, thus Format is basically useless by itself.
#Contains some methods that are applicable to all formats.
#Classes that inherit from Format are used as the means of obtaining information from a file to be used in Search2mzIdentML.
#Takes a string containing the search output file location and a string containing the FASTA  database that was used.
class Format
  def initialize(file, database)
    puts "\nPreparing..." if $VERBOSE
    
    @file = file
    @database = database
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
  
  #Retrieves the name of the search engine
  def searchEngine
    ""
  end
  
  #Retrieves the date in the file
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
  
  # Determines the accession number for the score type. For some reason, this has become the slowest part of the conversion.
  def findAccession(name)
    if arr = @obo[name]
      arr
    else
      ["", ""]
    end
  end
	
  # Conforms score name to mzIdentML format
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
end
