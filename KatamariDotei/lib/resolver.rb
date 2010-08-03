

class Resolver
  def initialize(file)
    @file = file
    @proteins = []
    @peptides = []
  end
  
  def resolve
    pepHash = Hash.new {|h,k| h[k] = []}
    proHash = Hash.new {|h,k| h[k] = []}
    
    File.open(@file, "r").each_line do |line|
      parts = line.chomp.split("\t")
      peptide = parts[4]
      proteins = parts[5..-1]
      
      proteins.each do |protein|
        pepHash[peptide] << protein
        proHash[protein] << peptide
      end unless proteins == nil
    end
    
    pepHash.each {|key, value| @peptides << [key, value, 0]}
    proHash.each {|key, value| @proteins << [key, value, 0]}
    
    0.upto(@peptides.length - 1).each do |i|
      @peptides[i][1].each {|protein| @peptides[i][2] += 1 if uniq?(@peptides, protein, i)}
    end
    
    @peptides = @peptides.sort_by {|item| [item[2], item[1].length]}
    @peptides.reverse!
    
    
    0.upto(@proteins.length - 1).each do |i|
      @proteins[i][1].each {|peptide| @proteins[i][2] += 1 if uniq?(@proteins, peptide, i)}
    end
    
    @proteins = @proteins.sort_by {|item| [item[2], item[1].length]}
    @proteins.reverse!
    
    resolve_array(@peptides)
    resolve_array(@proteins)
    
#    puts "\nSize of @peptides before: #{@peptides.length}"
#    puts "Size of @proteins before: #{@proteins.length}"
#    puts "Size of @proteins's peptides before: #{count_peptides(@proteins)}"
#    puts "Size of @peptides's proteins before: #{count_proteins(@peptides)}"
#    
#    resolve_peptides
#    resolve_proteins
#    
#    puts "\nSize of @peptides after: #{@peptides.length}"
#    puts "Size of @proteins after: #{@proteins.length}"
#    puts "Size of @proteins's peptides after: #{count_peptides(@proteins)}"
#    puts "Size of @peptides's proteins after: #{count_proteins(@peptides)}"
    
    [@peptides, @proteins]
  end
  
  
  private
  
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
  
  def resolve_array(array)
    pot_o_data = []
    
    array.each do |item|
      i = 0
      
      while i < item[1].length
        if pot_o_data.include? item[1][i]
          item[1].delete_at(i)
        else
          pot_o_data << item[1][i]
          i += 1
        end
      end
    end
    
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
  
  def resolve_peptides
    original_count = count_proteins(@peptides)
    i = 0
    
    while i < @peptides.length
      pair = @peptides.delete_at(i)
      
      if original_count > count_proteins(@peptides)
        @peptides.insert(i, pair)
        i += 1
      end
    end
  end
  
  def count_proteins(peptides)
    proteins = []
      
    peptides.each do |pair|
      pair[1].each {|x| proteins << x}
    end
    
    proteins.uniq.length
  end
  
  def resolve_proteins
    original_count = count_peptides(@proteins)
    i = 0
    
    while i < @proteins.length
      pair = @proteins.delete_at(i)
      
      if original_count > count_peptides(@proteins)
        @proteins.insert(i, pair)
        i += 1
      end
    end
  end
  
  def count_peptides(proteins)
    peptides = []
    proteins.each {|pair| peptides << pair[1]}
    
    peptides.uniq.length
  end
end
