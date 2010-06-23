require 'spec/more'
require "/home/jashi/pipeline/pipeline0.01/src/raw_to_mzxml.rb"

describe 'RawTomzXML' do
  before do
    @rawtmz = RawTomzXML.new("#{$vpath}data/043010_100430153139.raw")
  end
  
  it 'takes a raw file and outputs an mzXML file' do
    @rawtmz.convert
    Dir["#{$path}pipeline0.01/data/043010_100430153139.mzXML"].first.isnt nil
  end
end