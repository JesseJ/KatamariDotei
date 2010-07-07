require 'spec/more'
require 'fileutils'
require "#{File.dirname($0)}/search2mzidentml.rb"

describe 'PepXML2mzIdentML' do
  before do
    @p2mm = Search2mzIdentML.new(PepXML.new("#{File.dirname($0)}/test.pep.xml", "#{File.dirname($0)}/../databases/uni_human_var_100517_fwd.fasta"))
    #@p2mo = Search2mzIdentML.new(PepXML.new("#{File.dirname($0)}/test-omssa.pep.xml", "#{File.dirname($0)}/../databases/uni_human_var_100517_fwd.fasta"))
    #@p2mt = Search2mzIdentML.new(PepXML.new("#{File.dirname($0)}/test-tandem.pep.xml", "#{File.dirname($0)}/../databases/uni_human_var_100517_fwd.fasta"))
  end

  def same_header(doc1, doc2)
  end
  
  xit 'takes a pepXML file and outputs an mzIdentML file' do
    @p2mm.convert
    #@p2mo.convert
    #@p2mt.convert
        
    file1 = File.open("#{File.dirname($0)}/test-test.mzid")
    file2 = File.open("#{File.dirname($0)}/test.mzid")


    ok File.exist?(file1)
    #FileUtils::cmp(file1, file2).is true
  end
end


describe 'dealing with protein IDs' do
  it 'massages multiple ID types into a single, short ID' do
    {'QSASDF123243' => 'QSASDF123243', 'ASDF12|crazy protein description' => 'ASDF12', '1245' => 'hellonewprotein', 'IPI:IPI123451|QGASDF|ASDASDF' => 'IPI123451'}.each do |test, expected|
      obj = Object.new
      obj.instance_variable_set("@proteinIndices", {1245 => 'hellonewprotein'})
      obj.extend(PepXML::ProteinID)
      obj.proteinID(test).is expected
    end
  end
end



Bacon.summary_on_exit
