require "#{File.dirname($0)}/spect_id_result.rb"
require 'nokogiri'

#A base class for other file formats. Other formats are meant to inherit from this class, thus Format is useless by itself.
#Classes that inherit from Format are used as the means of obtaining information from a file to be used in Search2mzIdentML.
#Takes a string containing the search output file location and a string containing the FASTA  database that was used.
class Format
	def initialize(file, database)
		@doc = Nokogiri::XML(IO.read("#{File.dirname($0)}/obo.xml"))
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
	
	#Determines the accession number for the score type.
	def findAccession(name)
		@doc.xpath("//term[@name=\"#{name}\"]/@id").to_s
	end
end
