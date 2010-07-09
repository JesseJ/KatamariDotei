
#Is used to refine the input to search engines. A part of the iterative process of searching.
class Refiner
  #files == 
  #cutoff == The cutoff value. Only those above the cutoff value are kept
  #mzFile == The mzML or mzXML file that was used
  def initialize(files, cutoff, mzFile)
    @files = files
    @cutoff = cutoff
    @mzFile = mzFile
  end
    
  def refine
    puts "\n----------------"
    puts "Refining search...\n"
        
    
  end
end
