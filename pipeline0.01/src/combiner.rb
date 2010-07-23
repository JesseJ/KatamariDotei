
# Combines multiple .psms files into one .psms file using ....
class Combiner
  # files == Percolator.run output
  def initialize(files, run)
    @files = files
    @run = run
  end
  
  # Combines the files and writes it to a new psms file, returns the new file name.
  def combine
    puts "\n--------------------------------"
    puts "Combining search engine hits...\n"
    
    all_hits = create_array
    combined_hits = recalculate(all_hits)
    combined_hits = combined_hits.sort_by {|x| [x[0], x[4]]}
    
    combined_file = "#{$path}../data/combined_#{@run}.psms"
    File.open(combined_file, "w") do |file|
      combined_hits.each {|hit| file.print hit.join("\t") + "\n"}
    end
    
    combined_file
  end
  
  
  private
  
  # Creates an array of all the peptide hits
  def create_array
    all_hits = []
    
    @files.each do |file|
      file_name = file.chomp(".psms").split("_")[-1]
      File.open(file, "r").each do |line|
        parts = line.split("\t")
        next if parts[0] == "PSMId"
        id = parts[0].split(".")[1..3].join(".")
        prob = parts[3]
        peptide = parts[4]
        proteins = parts[5...-1].join("\t")
        
        all_hits << [id, file_name, 0, prob.to_f, peptide.chomp, proteins.chomp]
      end
    end
        
    all_hits.sort_by {|x| [x[0], x[4]]}
  end
  
  # Combines duplicates and recalculates posterior error probabilities and qvalues.
  def recalculate(all_hits)
    duplicates = [ [0, ["","","",""]] ]
    count = all_hits.length - 1
    
    0.upto(count) do |i|
      if all_hits[i][4] == duplicates[0][1][4]
        duplicates << [i, all_hits[i]]
      else
        if duplicates.length > 1
          name = ""
          pep = 0
          
          duplicates.each do |x| 
            name += x[1][1] + "+"
            pep += x[1][3]
          end
          
          name.chomp!("+")
          pep = pep / duplicates.length
          
          duplicates.each do |x|
            all_hits[x[0]][1] = name
            all_hits[x[0]][3] = pep
          end
        end
        
        duplicates = [ [i, all_hits[i]] ]
      end
    end
    
    recalculate_qvalues(all_hits.uniq!)
  end
  
  # Recaluculates the qvalues.
  def recalculate_qvalues(combined_hits)
    combined_hits = combined_hits.sort_by {|x| x[3]}
    count = combined_hits.length - 1
    sum = 0
    
    0.upto(count).each do |i|
      sum += combined_hits[i][3]
      combined_hits[i][2] = sum / (i + 1)
    end
    
    combined_hits
  end
  
  # Takes some input, does some crazy math function, and outputs some answer.
  def crazy_math_function
  end
end
