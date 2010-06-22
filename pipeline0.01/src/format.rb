require 'yaml'

#A base class for other file formats to be used in Search2Tab. Other formats are meant to inherit from this class, thus Format is basically useless by itself.
#Contains methods that can be used by all formats.
#Takes strings containing the target and decoy output file locations and the forward and reverse FASTA databases.
class Format
  def initialize(target, decoy, proteins, decoyProteins)
    @target = target
    @decoy = decoy
    
    @matches = []
    @proteins = proteins
    @decoyProteins = decoyProteins
  end
  
  #Returns the file name without things like "target" or ".pep.xml" in the name
  def fileWithoutExtras
    ""
  end
  
  def target
    ""
  end
  
  def decoy
    ""
  end
  
  def scores
    ""
  end
  
  def matches
    []
  end
  
  #Obtains all the proteins that the given peptide maps to.
  def proteins(peptide, type)
    if type == :target
      @proteins[peptide]
    elsif type == :decoy
      @decoyProteins[peptide]
    end
  end
end
