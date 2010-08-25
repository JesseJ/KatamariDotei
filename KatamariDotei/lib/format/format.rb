require 'yaml'

module PercolatorInput  # This is to prevent confusion between this Format and mzIdentML Format.
  # A base class for other file formats to be used in Search2Tab. Other formats are meant to inherit from this class, thus Format is basically useless by itself.
  # Contains methods that can be used by all formats.
  # Takes strings containing the target and decoy output file locations and the forward and reverse FASTA databases.
  #
  # @author Jesse Jashinsky (Aug 2010)
  class Format
    # @param [String] target the file location of the target file
    # @param [String] decoy the file location of the decoy file
    # @param [Hash] proteins a hash of peptides to proteins
    def initialize(target, decoy, proteins)
      @target = target
      @decoy = decoy
      
      @matches = []
      @proteins = proteins
    end
    
    # @return [String] file location without extension and target
    def fileWithoutExtras
      ""
    end
    
    # @return [String] the target file location
    def target
      ""
    end
    
    # @return [String] the decoy file location
    def decoy
      ""
    end
    
    # @return [Array(String)] an array of spectral matches
    def matches
      []
    end
    
    # Obtains all the proteins that the given peptide maps to.
    #
    # @param [String] peptide the peptide
    # @return [String] a tab seperated list of protein IDs
    def proteins(peptide)
      proteins = @proteins[peptide]
      return proteins if proteins != nil
      
      #Default value. Hopefully this case doesn't happen often.
      "NOMATCH"
    end
  end
end