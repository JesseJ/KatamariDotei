require "#{File.dirname($0)}/format.rb"

class PepXML < Format
	def initialize(file)
		@file = file
		@type = "pepxml"
		@doc = Nokogiri::XML(IO.read(file))
		@databaseName = ""
		@xmlns = ""
		
		#Nokogiri won't parse out the information of an XML file that uses namespaces unless you add xmlns, and vice versa.
		@xmlns = "xmlns:" if hasNamespace
	end
	
	#Checks if the pepXML file used namespaces
	def hasNamespace
		if @doc.xpath("xmlns:msms_pipeline_analysis").to_s.length != 0
			true
		else
			false
		end
	end
	
	def file
		@file
	end
	
	def type
		@type
	end
	
	#Retrieves the date in the pepXML file
	def date
        @doc.xpath("#{@xmlns}msms_pipeline_analysis/@date").to_s
	end
	
	#Retrieves all the proteins
	def proteins
		allHits = @doc.xpath("//#{@xmlns}search_hit/@protein|//#{@xmlns}search_hit/@protein_descr")
		pros = []
		i = 0
		while i < allHits.length
			pros << [allHits[i].to_s, allHits[i+1].to_s]
			i += 2
		end
		
		pros.uniq
	end
	
	#Retrieves all the peptides
	def peptides
		allHits = @doc.xpath("//#{@xmlns}search_hit/@peptide")
		peps = []
		allHits.each {|hit| peps << hit.to_s}
		
		peps.uniq
	end
	
	#Retrieves the name of the search database that was used
	def databaseName
		if @databaseName != ""
			return @databaseName
		else
			@databaseName = @doc.xpath("//#{@xmlns}search_database/@database_name").to_s
			return @databaseName
		end
	end
end