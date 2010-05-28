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
		
		#Nokogiri won't parse out the information of an XML file that uses namespaces unless you add xmlns, and vice versa.
		@xmlns = "xmlns:" if hasNamespace
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
	
	#Retrieves all the proteins
	def proteins
		allHits = @doc.xpath("//#{@xmlns}search_hit/@protein|//#{@xmlns}search_hit/@protein_descr")
		pros = []
		i = 0
		while i < allHits.length
			pros << [allHits[i].to_s, allHits[i+1].to_s]
			i += 2
		end
		
		pros.uniq!
		@pros = pros
		pros
	end
	
	#Retrieves all the peptides
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
			charge = query.xpath("./@assumed_charge").to_s.to_f
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
		if @doc.xpath("xmlns:msms_pipeline_analysis").to_s.length != 0
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
		
		#(:id, :mass, :charge, :experi, :pep, :rank, :pass)
		item = SpectIdItem.new(Ident.new(rank, calMass(mass, charge), charge, experiMass(mass, charge, diff), "peptide_?", rank, "true"))
		scoreArr = []
		
		scores.each do |score|
			name = score.xpath("./@name").to_s
			scoreArr << ["MS:?", name, score.xpath("./@value").to_s.to_f]
		end
		
		item.vals = scoreArr
		item.pepEvidence = getEvidence(hit) if rank == 1
		item
	end
	
	#Obtains the peptideEvidence
	def getEvidence(hit)
		pre = hit.xpath("./@peptide_prev_aa").to_s
		post = hit.xpath("./@peptide_next_aa").to_s
		missedCleavages = hit.xpath("./@num_missed_cleavages").to_s
		startVal, endVal = pepLocation(hit)
		
		
		#(:id, :start, :end, :pre, :post, :missedCleavages, :isDecoy, :DBSequence_Ref)
		PepEvidence.new("", startVal, endVal, pre, post, missedCleavages, false, "")
	end
	
	#Finds the start and end location of the peptide
	def pepLocation(hit)
		startVal = 0
		endVal = 0
		pep = hit.xpath("./@peptide").to_s
		pro = hit.xpath("./@protein").to_s
		
		Ms::Fasta.foreach(@database) do |entry|
			if entry.header[0..14].include? pro
				startVal = entry.sequence.scan_i(pep)[0]
				puts startVal
				puts entry
				if startVal != nil
					endVal = startVal + pep.length
					#break
				end
			end
		end
		
		puts "\n"
		
		return startVal, endVal
	end
end

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
