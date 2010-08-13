require 'set'
require "helper_methods"

PH = [:filename, :title, :aaseq, :pep, :qvalue, :search_engines, :charge, :prots]
PeptideHit =  Struct.new(*PH) do
  def inspect
    %Q{<PeptideHit#{object_id} filename="#{filename}" title="#{title}" aaseq="#{aaseq}" pep=#{pep} prots.size=#{prots.size}>}
  end
end
Protein = Struct.new(:id, :description, :peps, :spectral_counts, :unique_peptides) do
  def inspect
    %Q{<Protein#{object_id} id="#{id}"peps.size=#{peps.size}>}
  end
end

# Reduces proteins and peptides to the minimum unique peptides and proteins.
class Resolver
  # samples == The combined.psms files of each sample
  def initialize(samples)
    @samples = samples
    @proteins = []
    @peptides = []
  end
  
  # Resolves isoforms. Whatever those are.
  def resolve
    puts "\n--------------------------------"
    puts "Resolving isoforms...I think...\n\n"
    
    pepHash = Hash.new {|h,k| h[k] = []}
    proHash = Hash.new {|h,k| h[k] = []}
    
    # Places proteins and peptides into hashes for mapping
    @samples.each do |key, value|
      value.combined.each do |file|
        File.open(file, "r").each_line do |line|
          parts = line.chomp.split("\t")
          peptide = parts[4]
          proteins = parts[5..-1]
          
          proteins.each do |protein|
            pepHash[peptide] << protein
            proHash[protein] << peptide
          end unless proteins == nil
        end
      end
    end
    
    # Transfers contents of hashes to arrays to allow for sorting
    pepHash.each {|key, value| @peptides << [key, value, 0]}
    proHash.each {|key, value| @proteins << [key, value, 0]}
    
    # Count unique proteins and then sort accordingly
    0.upto(@peptides.length - 1).each do |i|
      @peptides[i][1].each {|protein| @peptides[i][2] += 1 if uniq?(@peptides, protein, i)}
    end
    
    @peptides = @peptides.sort_by {|item| [item[2], item[1].length]}
    @peptides.reverse!
    
    # Count unique peptides and then sort accordingly
    0.upto(@proteins.length - 1).each do |i|
      @proteins[i][1].each {|peptide| @proteins[i][2] += 1 if uniq?(@proteins, peptide, i)}
    end
    
    @proteins = @proteins.sort_by {|item| [item[2], item[1].length]}
    @proteins.reverse!
    
    resolve_array(@peptides)
    resolve_array(@proteins)
    
    [@peptides, @proteins]
  end
  
  # An adaptation of John Prince's code for resolving peptides.
  def prince_resolve
    puts "\n--------------------------------"
    puts "Resolving isoforms...\n\n"
    
    header = %w(title search_engines pep qvalue)
    cutoff = config_value("//Refiner/@cutoff").to_f
    files = []
      
    @samples.each do |key, value|
      value.combined.each {|file| files << file}
    end
    
    official_filenames = []
    all_prots_by_id = {}
    peptide_hits = files.map do |file|
      base = File.basename(file).chomp(File.extname(file))
      official_filenames << base
      IO.readlines(file).map do |line|
        t = line.chomp.split("\t")
        pep = t[2].to_f
        if pep < cutoff
          hit = PeptideHit.new
          hit.title = t[0]
          hit.search_engines = t[1].split('+')
          hit.charge = t[0].split('.')[-1]
          hit.pep = pep
          hit.qvalue = t[3].to_f
          hit.aaseq = t[4]
          hit.prots = t[5..-1].map do |id|
            prot = 
              if all_prots_by_id.key?(id)
                all_prots_by_id[id]
              else
                all_prots_by_id[id] = Protein.new(id, nil, [])
              end
            prot.peps << hit
            prot
          end
          hit.filename = base
          hit
        end
      end.compact
    end
    
    minimum_proteins!(peptide_hits.flatten)
  end
  
  
  private
  
  # Determines if the given value is unique amongst all values of the array
  def uniq?(array, value, i)
    array[i][1].delete_at(array[i][1].index(value))
    
    array.each do |item|
      if item[1].include? value
        array[i][1].insert(0, value)
        return false 
      end
    end
    
    array[i][1].insert(0, value)

    true
  end
  
  # Resolves the matter for the given array
  def resolve_array(array)
    pot_o_data = []  #Holds the previously seen values
    
    array.each do |item|
      i = 0
      
      # Removes duplicate values
      while i < item[1].length
        if pot_o_data.include? item[1][i]
          item[1].delete_at(i)
        else
          pot_o_data << item[1][i]
          i += 1
        end
      end
    end
    
    # Removes items with empty values and removes the uniq values counter
    i = 0
    while i < array.length
      if array[i][1].empty?
        array.delete_at(i)
      else
        array[i] = [array[i][0], array[i][1]]
        i += 1
      end
    end
  end
  
  # modifies the set
  # John Prince's method
  def minimum_proteins!(peptide_hits)
    #peptide_hit responds to  .prots
    #peptide_hit responds to  .aaseq
    
    #protein_hit responds to  .id
    #protein_hit responds to  .peps
    
    prot_to_peps, most_overlap, pep_to_prots = prepare_data(peptide_hits)
  
    prot_to_peps_sorted = prot_to_peps.sort_by do |prot, peps|
      # e.g. [ 0, 3, 2, 5]
      # [ 3 peptides with 1 unique protein, 2 peptides with 2 unique proteins,
      # 5 peptides with 3 unique proteins ]
      # !! the first index is always zero
      uniqueness_ar = Array.new(most_overlap+1,0)
      peps.each do |pep|
        size = pep_to_prots[pep].size
        uniqueness_ar[pep_to_prots[pep].size] += 1 # the num of proteins pep belongs to
      end
      uniqueness_ar
    end.reverse
  
    peps_seen = Set.new
    final_output_hash = {}
    prot_to_peps_sorted.each do |prot, peps_set|
      refined = peps_set.to_a.reject do |pep|
        if peps_seen.include?(pep)
          true
        else
          peps_seen << pep
          false
        end
      end
      
      final_output_hash[prot] = refined if refined.size > 0
    end
    
    final_peps_to_prots = Hash.new{ |h,k| h[k] = [] }
    final_output_hash.each do |prot, peps|
      peps.each {|pep| final_peps_to_prots[pep] << prot}
    end
    
    update_hits(peptide_hits, final_peps_to_prots)
  end
  
  # INTRO: convert objects to lowest level hashes
  # peptide aaseq => [protein id, protein id...]
  # protein id => [aaseq, aaseq, aaseq...]
  # prot_to_pep and pep_to_prot  (all by id)
  def prepare_data(peptide_hits)
    prot_to_peps = Hash.new{ |h,k| h[k] = Set.new }
    pep_to_prots = {}
  
    peptide_hits.group_by(&:aaseq).each do |aaseq, hits|
      prots = hits.first.prots
      pep_to_prots[aaseq] = prots.map(&:id)
      prots.each do |prot|
        prot_to_peps[prot.id] << aaseq
      end
    end
  
    most_overlap = pep_to_prots.values.map(&:size).max
    
    return prot_to_peps, most_overlap, pep_to_prots
  end
  
  # UPDATE CODE: update the peptide hits with new proteins and proteins with new peptide hits
  # update the peptide hits with minimum_proteins and proteins with peptides
  def update_hits(peptide_hits, final_peps_to_prots)
    peptide_hits.each do |pep|
      pep.prots = pep.prots.select do |prot| 
        prot.peps = []  # clear the peptides
        #final_peps_to_prots.each {|k,v| puts "K: #{k} V: #{v}"; break }
        final_peps_to_prots[pep.aaseq].include?(prot.id) 
      end
    end
  
    peptide_hits.each do |pep_hit|
      pep_hit.prots.each do |prot|
        prot.peps.push(pep_hit)
      end
    end
    
    peptide_hits
  end
end
