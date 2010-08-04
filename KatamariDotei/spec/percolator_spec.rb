require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../lib/percolator"

describe 'Percolator' do
  before do
    @files = [["/home/jashi/pipeline/KatamariDotei/data/search/test_1-target_omssa.pep.xml", "/home/jashi/pipeline/KatamariDotei/data/search/test_1-decoy_omssa.pep.xml"], ["/home/jashi/pipeline/KatamariDotei/data/search/test_1-target_tandem.pep.xml", "/home/jashi/pipeline/KatamariDotei/data/search/test_1-decoy_tandem.pep.xml"], ["/home/jashi/pipeline/KatamariDotei/data/search/test_1-target_tide.pep.xml", "/home/jashi/pipeline/KatamariDotei/data/search/test_1-decoy_tide.pep.xml"], ["/home/jashi/pipeline/KatamariDotei/data/search/test_1-target_mascot.pep.xml", "/home/jashi/pipeline/KatamariDotei/data/search/test_1-decoy_mascot.pep.xml"]]
  end
  
  it 'takes the search engine outputs, creates .tab files from them, and runs Percolator on the .tab files.' do
    Percolator.new(@files, "human").run
    
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/percolator/test_1_mascot.psms", "r"), File.open("#{File.dirname($0)}/test_files/test_1_mascot-key.psms", "r")).is true
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/percolator/test_1_tandem.psms", "r"), File.open("#{File.dirname($0)}/test_files/test_1_tandem-key.psms", "r")).is true
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/percolator/test_1_omssa.psms", "r"), File.open("#{File.dirname($0)}/test_files/test_1_omssa-key.psms", "r")).is true
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/percolator/test_1_tide.psms", "r"), File.open("#{File.dirname($0)}/test_files/test_1_tide-key.psms", "r")).is true
  end
end
