
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
    
    all_hits = []  #Scans to use in the next search iteration.
    
    @files.each do |file|
      file_name = file.chomp(".psms").split("_")[-1]
      File.open(file, "r").each do |line|
        parts = line.split("\t")
        next if parts[0] == "PSMId"
        id = parts[0].split(".")[1..3].join(".")
        qvalue = parts[2]
        prob = parts[3]
        peptide = parts[4]
        proteins = parts[5...-1].join("\t")
        
        all_hits << [id, file_name, qvalue, prob, peptide.chomp, proteins.chomp]
      end
    end
    
    combined_hits = all_hits.sort_by {|x| [x[0], x[4]]}
    
    combined_file = "#{$path}../data/combined_#{@run}.psms"
    File.open(combined_file, "w") do |file|
      combined_hits.each {|hit| file.print hit.join("\t") + "\n"}
    end
    
    combined_file
  end
  
  # Takes some input, does some crazy math function, and outputs some answer.
  def crazy_math_function
  end
end
