$path = "#{File.dirname($0)}/../src/"  #This needs to be set since we're not running it from pipeline.rb

require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../src/percolator"

describe 'RawToMzml' do
  before do
    @files = [["/home/jashi/pipeline/pipeline0.01/src/../data/test_1-target_omssa.pep.xml", "/home/jashi/pipeline/pipeline0.01/src/../data/test_1-decoy_omssa.pep.xml"], ["/home/jashi/pipeline/pipeline0.01/src/../data/test_1-target_tandem.pep.xml", "/home/jashi/pipeline/pipeline0.01/src/../data/test_1-decoy_tandem.pep.xml"], ["/home/jashi/pipeline/pipeline0.01/src/../data/test_1-target_tide.pep.xml", "/home/jashi/pipeline/pipeline0.01/src/../data/test_1-decoy_tide.pep.xml"], ["/home/jashi/pipeline/pipeline0.01/src/../data/test_1-target_mascot.pep.xml", "/home/jashi/pipeline/pipeline0.01/src/../data/test_1-decoy_mascot.pep.xml"]]
  end
  
  it 'takes the search engine outputs, creates .tab files from them, and runs Percolator on the .tab files.' do
    Percolator.new(@files, "human").run
    
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/test_1_mascot.psms", "r"), File.open("#{File.dirname($0)}/test_1_mascot-key.psms", "r")).is true
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/test_1_tandem.psms", "r"), File.open("#{File.dirname($0)}/test_1_tandem-key.psms", "r")).is true
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/test_1_omssa.psms", "r"), File.open("#{File.dirname($0)}/test_1_omssa-key.psms", "r")).is true
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/test_1_tide.psms", "r"), File.open("#{File.dirname($0)}/test_1_tide-key.psms", "r")).is true
  end
end
