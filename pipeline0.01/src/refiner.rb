
# Is used to refine the input to search engines. A part of the iterative process of searching.
class Refiner
  # file == combiner.rb output
  # cutoff == The cutoff value. Only those above the cutoff value are kept
  # mzFile == The mzML or mzXML file that was used
  def initialize(file, cutoff, mzFile)
    @file = file
    @cutoff = cutoff
    @mzFile = mzFile
  end
  
  # Determines which scans to include and creates a new (mgf and/or ms2) file.
  def refine
    puts "\n----------------"
    puts "Refining search...\n"
    
    write_to_msms(refine_scans)
  end
  
  # Determines which scans to include.
  def refine_scans
    selected_scans = []  #Scans to use in the next search iteration.
    
    File.open(@file, "r").each do |line|
      parts = line.split("\t")
      spectrum = parts[0].split(".")[1].to_i
      score = parts[1].to_i
      qvalue = parts[2].to_f
      prob = parts[3].to_f
      
      selected_scans << spectrum if qvalue > @cutoff
    end
    
    selected_scans
  end
  
  # Writes the given scans to mgf and ms2
  def write_to_msms(selected_scans)
    Ms::Msrun.open(@mzFile) do |ms|
      fName = @mzFile.chomp(File.extname(@mzFile))
      ms.to_mgf(:output => fName + ".ms2", :selected_scans => selected_scans)
      ms.to_ms2(:output => fName + ".ms2", :selected_scans => selected_scans)
    end
  end
end
