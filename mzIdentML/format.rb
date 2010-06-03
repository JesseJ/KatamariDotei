require "#{File.dirname($0)}/spect_id_result.rb"
require 'nokogiri'

#A base class for other file formats. Other formats are meant to inherit from this class, thus Format is useless by itself.
#Classes that inherit from Format are used as the means of obtaining information from a file to be used in Search2mzIdentML.
#Takes a string containing the search output file location and a string containing the FASTA  database that was used.
class Format
	def initialize(file, database)
		@obo
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
	
	#Retrieves the threshold value
	def threshold
		0
	end
	
	#Retrieves all the proteins
	def proteins
		[]
	end
	
	#Retrieves all the peptides
	def peptides
		[]
	end
	
	#Retrieves the name of the search database that was used
	def databaseName
		""
	end
	
	#Retrieves the results of the search engine
	def results
		[]
	end
	
	#Retrieves the number of database sequences
	def numberOfSequences
		0
	end
	
	#Converts calc_neutral_pep_mass to calculatedMassToCharge
	def calMass(mass, charge)
	  	(mass + (charge.to_f * 1.00727646677)) / charge
	end
				
	#Converts calc_neutral_pep_mass to experimentalMassToCharge
	def experiMass(mass, charge, diff)
		((mass + diff) + (charge.to_f * 1.00727646677)) / charge
	end
	
	#Determines the accession number for the score type. For some reason, this has become the slowest part of the conversion.
	#Might be able to increase speed by switching to hash, or removing uneeded terms.
	def findAccession(name)
		@obo = Nokogiri::XML(IO.read("#{File.dirname($0)}/oboe.xml")) if @obo == nil
		
		@obo.xpath("//term[@name=\"#{name}\"]/@id").to_s
	end
	
	#Conforms score name to mzIdentML format
	def conformScoreName(name, engine)
		if engine == "X! Tandem"
			name = "xtandem:" + name
		elsif engine == "MASCOT"
			name = "mascot:" + name
		elsif engine == "OMSSA"
			name = "OMSSA:" + name
		end
		
		name
	end
end
