
# Is used to refine the input to search engines. A part of the iterative process of searching.
#
# @author Jesse Jashinsky (Aug 2010)
class Refiner
  # @param [String] file Combiner.combine output
  # @param [String] cutoff the cutoff value. Only those above the cutoff value are kept
  # @param [String] mzFile the location of the mzML file that was used
  def initialize(file, cutoff, mzFile, run)
    @file = file
    @cutoff = cutoff
    @mzFile = mzFile
    @run = run
  end
  
  # Determines which scans to include and creates a new mgf and/or ms2 file.
  #
  # @return [String] the location of the new mgf file
  def refine
    puts "\n--------------------------------"
    puts "Refining search...\n"
    
    write_to_msms(refine_scans)
    @mzFile.chomp(File.extname(@mzFile)) + "_#{@run}.mgf"
  end
  
  # Determines which scans to include.
  #
  # @return [Array(Number)] the selected scans to include
  def refine_scans
    selected_scans = []  #Scans to use in the next search iteration.
    
    File.open(@file, "r").each do |line|
      parts = line.split("\t")
      spectrum = parts[0].split(".")[1].to_i
      qvalue = parts[2].to_f
      
      selected_scans << spectrum if qvalue > @cutoff
    end
    
    selected_scans
  end
  
  # Writes the given scans to mgf and ms2
  def write_to_msms(selected_scans)
    Ms::Msrun.open(@mzFile) do |ms|
      fName = @mzFile.chomp(File.extname(@mzFile)) + "_#{@run}"
      ms.to_mgf(:output => fName + ".mgf", :included_scans => selected_scans)
      ms.to_ms2(:output => fName + ".ms2", :included_scans => selected_scans)
    end
  end
end
