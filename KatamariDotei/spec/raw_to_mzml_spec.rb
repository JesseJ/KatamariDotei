$path = "#{File.dirname($0)}/../src/"  #This needs to be set since we're not running it from pipeline.rb

require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../src/raw_to_mzml.rb"

describe 'RawToMzml' do
  before do
    @rawtmz = RawToMzml.new("#{File.dirname($0)}/../data/test")
  end
  
  it 'takes a raw file and outputs an mzXML or mzML file' do
    @rawtmz.to_mzXML
    @rawtmz.to_mzML
    
    Dir["#{File.dirname($0)}/../data/test.mzXML"].first.isnt nil
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/test.mzML", "r"), File.open("#{File.dirname($0)}/test-key.mzML", "r")).is true
  end
end

