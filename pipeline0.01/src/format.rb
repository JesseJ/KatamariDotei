
#A base class for other file formats to be used in Search2Tab. Other formats are meant to inherit from this class, thus Format is basically useless by itself.
#Takes strings containing the original file, target, and the decoy file locations and a string containing the FASTA database.
class Format
  def initialize(target, decoy)
    @target = target
    @decoy = decoy
    @matches = []
  end
  
  #Returns the file name without things like "forward" or ".pep.xml" in the name
  def file
    @file = file
  end
  
  def target
    ""
  end
  
  def decoy
    ""
  end
  
  def matches
    []
  end
end