require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../lib/raw_to_mzml.rb"

describe 'RawToMzml' do
  before do
    @rawtmz = RawToMzml.new("#{File.dirname($0)}/test_files/test.raw")
  end
  
  it 'takes a raw file and outputs an mzXML or mzML file' do
    @rawtmz.to_mzXML
    @rawtmz.to_mzML
    
    Dir["#{File.dirname($0)}/../data/spectra/test.mzXML"].first.isnt nil
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/spectra/test.mzML", "r"), File.open("#{File.dirname($0)}/test_files/test-key.mzML", "r")).is true
  end
end

