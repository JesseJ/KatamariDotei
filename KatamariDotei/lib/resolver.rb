
# Reduces proteins and peptides to the minimum unique peptides and proteins.
class Resolver
  # files == The combined.psms files of each sample
  def initialize(files)
    @files = files
    @proteins = []
    @peptides = []
  end
  
  # Resolves isoforms
  def resolve
    puts "\n--------------------------------"
    puts "Resolving isoforms...I think...\n\n"
    
    pepHash = Hash.new {|h,k| h[k] = []}
    proHash = Hash.new {|h,k| h[k] = []}
    
    # Places proteins and peptides into hashes for mapping
    File.open(@file, "r").each_line do |line|
      parts = line.chomp.split("\t")
      peptide = parts[4]
      proteins = parts[5..-1]
      
      proteins.each do |protein|
        pepHash[peptide] << protein
        proHash[protein] << peptide
      end unless proteins == nil
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
end
