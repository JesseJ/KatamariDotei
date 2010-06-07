require 'spec/more'
require 'fileutils'
require "#{File.dirname($0)}/search2mzIdentML.rb"


describe 'PepXML2mzIdentML' do
    before do
        @p2mm = Search2mzIdentML.new(PepXML.new("#{File.dirname($0)}/test.pep.xml", "#{File.dirname($0)}/../databases/uni_human_var_100517_fwd.fasta"))
        #@p2mo = Search2mzIdentML.new(PepXML.new("#{File.dirname($0)}/test-omssa.pep.xml", "#{File.dirname($0)}/../databases/uni_human_var_100517_fwd.fasta"))
        #@p2mt = Search2mzIdentML.new(PepXML.new("#{File.dirname($0)}/test-tandem.pep.xml", "#{File.dirname($0)}/../databases/uni_human_var_100517_fwd.fasta"))
    end
	
    it 'takes a pepXML file and outputs an mzIdentML file' do
        @p2mm.convert
        #@p2mo.convert
        #@p2mt.convert
        
        file1 = File.open("#{File.dirname($0)}/test-test.mzid")
        file2 = File.open("#{File.dirname($0)}/test.mzid")
        FileUtils::cmp(file1, file2).is true
    end
end

Bacon.summary_on_exit