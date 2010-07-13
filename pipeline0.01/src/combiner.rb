
# Combines multiple .psms files into one .psms file using ....
class Combiner
  # files == Percolator.run output
  def initialize(files, run)
    @files = files
    @run = run
  end
  
  # Combines the files and writes it to a new psms file, returns the new file name.
  def combine
    puts "\n----------------"
    puts "Combining search engine hits...\n"
    
    all_hits = []  #Scans to use in the next search iteration.
    
    @files.each do |file|
      File.open(file, "r").each do |line|
        parts = line.split("\t")
        next if parts[0] == "PSMId"
        id = parts[0].split(".")[1..3].join(".")
        score = parts[1]
        qvalue = parts[2]
        prob = parts[3]
        rest = parts[4...-1].join("\t")
        
        all_hits << [id, score, qvalue, prob, rest]
      end
    end
    
    combined_hits = all_hits.sort_by {|x| x[0]}
    
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
