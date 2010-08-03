$path = "#{File.dirname($0)}/../lib/"  #This needs to be set since we're not running it from pipeline.rb

require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../lib/mzml_to_other"

describe 'MzmlToOther' do
  
#  it 'takes an mzXML and runs Hardklor' do
#    MzmlToOther.new("mgf", "#{File.dirname($0)}/../data/test.mzXML", 1, true).convert
#    
#    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/test_1.mgf", "r"), File.open("#{File.dirname($0)}/mzXML-test_1-key.mgf", "r")).is true
#  end
  
  it 'takes an mzXML or mzML file and outputs an mgf or ms2 file' do
    MzmlToOther.new("mgf", "#{File.dirname($0)}/../data/spectra/test.mzXML", 1, false).convert
    MzmlToOther.new("ms2", "#{File.dirname($0)}/../data/spectra/test.mzXML", 1, false).convert
    
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/spectra/test_1.mgf", "r"), File.open("#{File.dirname($0)}/mzXML-test_1-key.mgf", "r")).is true
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/spectra/test_1.ms2", "r"), File.open("#{File.dirname($0)}/mzXML-test_1-key.ms2", "r")).is true
      
    MzmlToOther.new("mgf", "#{File.dirname($0)}/../data/spectra/test.mzML", 1, false).convert
    MzmlToOther.new("ms2", "#{File.dirname($0)}/../data/spectra/test.mzML", 1, false).convert
    
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/spectra/test_1.mgf", "r"), File.open("#{File.dirname($0)}/mzML-test_1-key.mgf", "r")).is true
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/spectra/test_1.ms2", "r"), File.open("#{File.dirname($0)}/mzML-test_1-key.ms2", "r")).is true
  end
end
