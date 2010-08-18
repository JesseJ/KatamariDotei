require 'yaml'

module PercolatorInput  #This is to prevent confusion between this Format and mzIdentML Format.
  #A base class for other file formats to be used in Search2Tab. Other formats are meant to inherit from this class, thus Format is basically useless by itself.
  #Contains methods that can be used by all formats.
  #Takes strings containing the target and decoy output file locations and the forward and reverse FASTA databases.
  class Format
    #target == A string containing the file location of the target pepXML
    #decoy == A string containing the file location of the decoy pepXML
    #database == A hash of target {peptide => proteins}
    #revDatabase == A hash of decoy {peptide => proteins}
    def initialize(target, decoy, proteins)
      @target = target
      @decoy = decoy
      
      @matches = []
      @proteins = proteins
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
    def proteins(peptide)
      proteins = @proteins[peptide]
      return proteins if proteins != nil
      
      #Default value. Hopefully this case doesn't happen often.
      "NOMATCH"
    end
  end
end