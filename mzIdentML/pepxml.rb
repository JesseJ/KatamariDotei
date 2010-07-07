require "#{File.dirname($0)}/format.rb"
require "#{File.dirname($0)}/natcmp.rb"
require "ms/fasta.rb"

class PepXML < Format
  def initialize(file, database)
    super
    @type = "pepxml"
    @doc = Nokogiri::XML(IO.read(file))
    @xmlns = ""
    @sequences = 0
    @proteinIndices = []
    
    #Nokogiri won't parse out the information of an XML file that uses namespaces unless you add xmlns, and vice versa.
    @xmlns = "xmlns:" if hasNamespace
    
    findAllPepLocations
    
    temp = database.split("/")
    @databaseName = temp[temp.length-1]
    
    @engine = @doc.xpath("//#{@xmlns}search_summary/@search_engine").to_s
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
    @engine
  end
  
  #Simply returns 0 because I don't know how to obtain the threshold from pepXML
  def threshold
    0
  end
  
  #Retrieves all the proteins. Not sure if this is correct.
  def proteins
    allHits = @doc.xpath("//#{@xmlns}search_hit/@protein|//#{@xmlns}search_hit/@protein_descr")
    pros = []
    i = 0
    
    while i < allHits.length
      pro = proteinID(allHits[i].to_s)
      pros << [pro, allHits[i+1].to_s, "DBSeq_1_#{pro}"]
      i += 2
    end
    
    @pros = pros.uniq
    @pros
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
  
  #Retrieves the name of the search database that was used.
  def databaseName
    @databaseName
  end
  
  #Retrieves the spectrum queries. Spectrum indexs not guarenteed to be correct.
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
      id, name = findAccession(conformScoreName(score.xpath("./@name").to_s, @engine))
      scoreArr << [id, name, score.xpath("./@value").to_s] if id != ""
    end
    
    item.vals = scoreArr
    item.pepEvidence = getEvidence(hit, pep, ref)
    item
  end
  
  #Obtains the peptideEvidence
  def getEvidence(hit, pep, id)
    pre = hit.xpath("./@peptide_prev_aa").to_s
    post = hit.xpath("./@peptide_next_aa").to_s
    missedCleavages = hit.xpath("./@num_missed_cleavages").to_s
    pro = proteinID(hit.xpath("./@protein").to_s)
    startVal, endVal = pepLocation(hit, pro, pep)
    ref = ""
    
    @pros.each do |thisPro|
      if pro == thisPro[0]
        ref = thisPro[2]
        break
      end
    end
    
    #(:id, :start, :end, :pre, :post, :missedCleavages, :isDecoy, :DBSequence_Ref)
    PepEvidence.new(id, startVal, endVal, pre, post, missedCleavages, false, ref)
  end
  
  #Gets the start and end location of the peptide
  def pepLocation(hit, pro, pep)
    @locations.each do |location|
      if location[0] == pep && location[1] == pro
        return location[2], location[3]
      end
    end
    
    return 0, 0    #In case it doesn't find anything
  end
  
  #Obtains all peptide locations and puts them in an array in the format: [[peptide, protein, start, end]]
  def findAllPepLocations
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
    dataHash = Hash.new
    
    Ms::Fasta.foreach(@database) do |entry|
      @sequences += 1
      pID = proteinID(entry.header)
      dataHash[pID] = entry.sequence
      @proteinIndices << pID
    end
    
    all.each do |set|
      if dataHash[set[1]] != nil
        startVal = dataHash[set[1]].scan_i(set[0])[0]
        
        if startVal != nil
          @locations << [set[0], set[1], startVal + 1, startVal + set[0].length]
        end
      end
    end
  end
  
  #Not all pepXML files simply list the protein ID, so this method obtains it.
  #Are there other cases to cover?
  def proteinID(protein)
    #A protein ID is 6-8 characters long, so if it's longer than that, then it contains more than just the ID
    if protein.length > 8
      arr = protein.split("|")[1].split(":")
      
      if arr.length == 1
        arr[0]
      else
        arr[1]
      end
    #If there's no characters, then it's an index. I don't fully understand regexp, but this works.
    elsif (protein =~ /[A-Z]/) == nil
      @proteinIndices[protein.to_i]
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
