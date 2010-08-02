

class Resolver
  def initialize(file)
    @file = file
    @proteins = []
    @peptides = []
  end
  
  def resolve
    File.open(@file, "r").each_line do |line|
      parts = line.split("\t")
      peptide = parts[4]
      proteins = parts[5..-1]
      
      @peptides << [peptide, proteins] unless proteins.empty?
      proteins.each {|x| @proteins << [x, peptide]}
    end
    
    @peptides.uniq!
    @proteins.uniq!
    
    puts "\nSize of @peptides before: #{@peptides.length}"
    puts "Size of @proteins before: #{@proteins.length}"
    puts "Size of @proteins's peptides before: #{count_peptides(@proteins)}"
    puts "Size of @peptides's proteins before: #{count_proteins(@peptides)}"
    
    resolve_peptides
    resolve_proteins
    
    puts "\nSize of @peptides after: #{@peptides.length}"
    puts "Size of @proteins after: #{@proteins.length}"
    puts "Size of @proteins's peptides after: #{count_peptides(@proteins)}"
    puts "Size of @peptides's proteins after: #{count_proteins(@peptides)}"
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
