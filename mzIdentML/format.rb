require 'nokogiri'

#A base class for other file formats. Other formats are meant to inherit from this class, thus Format is useless by itself.
#Classes that inherit from Format are used as the means of obtaining information from a file to be used in Search2mzIdentML.
#Takes a string containing the file location.
class Format
	def initialize(file)
		@file = file
		@type = "invalid"
	end
	
	def file
		@file
	end
	
	def type
		@type
	end
	
	#Retrieves the date in the file
	def date
		""
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
end