require "#{File.dirname($0)}/format.rb"
require "#{File.dirname($0)}/natcmp.rb"
require "#{File.dirname($0)}/../ms-fasta/lib/ms/fasta.rb"
require 'natural_sort_kernel'

class PepXML < Format
	def initialize(file, database)
		@file = file
		@database = database
		@type = "pepxml"
		@doc = Nokogiri::XML(IO.read(file))
		@databaseName = ""
		@xmlns = ""
		@tempSolution = 0
		@sequences = 0
		
		#Nokogiri won't parse out the information of an XML file that uses namespaces unless you add xmlns, and vice versa.
		@xmlns = "xmlns:" if hasNamespace
		
		findAllPepLocations
	end
	
	def file
		@file
	end
	
	def type
		@type
	end
	
	def database
		@database
	end
	
	#Retrieves the date in the pepXML file
	def date
        @doc.xpath("#{@xmlns}msms_pipeline_analysis/@date").to_s
	end
	
	#Retrieves the number of database sequences
	def numberOfSequences
		@sequences
	end
	
	#Retrieves the name of the search engine
	def searchEngine
		@doc.xpath("//#{@xmlns}search_summary/@search_engine").to_s
	end
	
	#Simply returns 0.05 because threshold can't be obtained from pepXML
	def threshold
		0.05
	end
	
	#Retrieves all the proteins. Not sure if this is correct.
	def proteins
		allHits = @doc.xpath("//#{@xmlns}search_hit/@protein|//#{@xmlns}search_hit/@protein_descr")
		pros = []
		i = 0
		while i < allHits.length
			pros << [allHits[i].to_s, allHits[i+1].to_s, "DBSeq_1_#{allHits[i].to_s}"]
			i += 2
		end
		
		pros.uniq!
		@pros = pros
		pros
	end
	
	#Retrieves all the peptides. Not sure if this is correct.
	def peptides
		allHits = @doc.xpath("//#{@xmlns}search_hit/@peptide")
		peps = []
		allHits.each {|hit| peps << hit.to_s}
		peps.uniq!
		
		i = 0
		first = 1
		second = 1
		while i < peps.length
			peps[i] = ["peptide_#{first}_#{second}", peps[i]]
			
			i += 1
			second += 1
			
			if second == 11
				first += 1
				second = 1
			end
		end
		
		@peps = peps
		peps
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
	
	#Retrieves the spectrum queries.
	def results
		queries = @doc.xpath("//#{@xmlns}spectrum_query")
		indicies = @doc.xpath("//#{@xmlns}spectrum_query/@spectrum").collect {|index| index.to_s}
		indicies = indicies.sort {|x,y| String.natcmp(x, y)}
		results = []
		
		queries.each do |query|
			charge = query.xpath("./@assumed_charge").to_s.to_i
			hits = query.xpath(".//#{@xmlns}search_hit")
			items = []
			rank = 1
			
			hits.each do |hit|
				items << getItem(hit, rank, charge)
				rank += 1
			end
			
			results << SpectIdResult.new(indicies.index(query.xpath("./@spectrum").to_s), items)
		end
		
		results
	end
	
	
	private
	
	#Checks if the pepXML file used namespaces
	def hasNamespace
		if @doc.xpath("msms_pipeline_analysis").to_s.length == 0
			true
		else
			false
		end
	end
	
	#Obtains the result items
	def getItem(hit, rank, charge)
		mass = hit.xpath("./@calc_neutral_pep_mass").to_s.to_f
		diff = hit.xpath("./@massdiff").to_s.to_f
		scores = hit.xpath(".//#{@xmlns}search_score")
		pep = hit.xpath("./@peptide").to_s
		ref = ""
		
		@peps.each do |thisPep|
			if pep == thisPep[1]
				ref = thisPep[0]
				break
			end
		end
		
		#(:id, :mass, :charge, :experi, :pep, :rank, :pass)
		item = SpectIdItem.new(Ident.new(rank, calMass(mass, charge), charge, experiMass(mass, charge, diff), ref, rank, "true"))
		scoreArr = []
		
		scores.each do |score|
			name = score.xpath("./@name").to_s
			scoreArr << [findAccession(name), name, score.xpath("./@value").to_s.to_f]
		end
		
		item.vals = scoreArr
		item.pepEvidence = getEvidence(hit)
		item
	end
	
	#Obtains the peptideEvidence
	def getEvidence(hit)
		pre = hit.xpath("./@peptide_prev_aa").to_s
		post = hit.xpath("./@peptide_next_aa").to_s
		missedCleavages = hit.xpath("./@num_missed_cleavages").to_s
		pro = hit.xpath("./@protein").to_s
		startVal, endVal = pepLocation(hit, pro)
		ref = ""
		
		@pros.each do |thisPro|
			if pro == thisPro[0]
				ref = thisPro[2]
				break
			end
		end
		
		@tempSolution += 1
		#(:id, :start, :end, :pre, :post, :missedCleavages, :isDecoy, :DBSequence_Ref)
		PepEvidence.new("PE_#{@tempSolution}_#{pro}", startVal, endVal, pre, post, missedCleavages, false, ref)
	end
	
	#Gets the start and end location of the peptide
	def pepLocation(hit, pro)
		pep = hit.xpath("./@peptide").to_s
		
		@locations.each do |location|
			if location[0] == pep && location[1] == pro
				return location[2], location[3]
			end
		end
		
		return 0, 0		#In case it doesn't find anything
	end
	
	#Obtains all peptide locations and puts them in an array in the format: [[peptide, protein, start, end]]
	def findAllPepLocations
		#hits = @doc.xpath("//#{@xmlns}search_hit[@hit_rank=\"1\"]")
		hits = @doc.xpath("//#{@xmlns}search_hit")
		all = []
		@locations = []
		i = 0
		
		#Parses out each peptide and protein
		hits.each do |hit|
			all << [hit.xpath("./@peptide").to_s, proteinID(hit.xpath("./@protein").to_s)]
			i += 1
		end
		
		all.uniq!
		
		#Cycles through each fasta entry in the database
		Ms::Fasta.foreach(@database) do |entry|
			i = 0
			@sequences += 1
			
			#Cycles through each peptide/protein
			while i < all.length
				set = all[i]
				
				#Checks if the header has the protein. 1..40 is used to limit the amount of characters
				#it compares to, and | is used to mark the end of the comparison
				if entry.header[1..40].include? set[1]
					startVal = entry.sequence.scan_i(set[0])[0]
					
					if startVal != nil
						@locations << [set[0], set[1], startVal + 1, startVal + set[0].length]
						all.delete_at(i)	#Greatly speeds up this method
						i -= 1
						p all.length
					end
				end
				
				i += 1
			end
		end
	end
	
	#Not all pepXML files simply list the protein ID, so this method obtains it
	#Needs to be expanded to cover other cases
	def proteinID(protein)
		#A protein ID is 6 characters long, so if it's longer than that, then it contains more than just the ID
		if protein.length > 6
			protein[3..8]	#Only works for the uniprot fasta format. Needs to be expanded.
		#If it's less than 6, then it must be a number
		elsif protein.length < 6
			protein		#Somehow need to match this number to an ID
		else
			protein
		end
	end
end

#For quickly getting the start and end indexes of a string
class String
	def scan_i seq
		pos = 0
		ndx = []
		slen = seq.length
		
		while i = index(seq,pos)
			ndx << i
			pos = i + slen
		end
		
		ndx
	end
end
