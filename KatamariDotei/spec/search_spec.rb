$path = "#{File.dirname($0)}/../lib/"  #This needs to be set since we're not running it from pipeline.rb

require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../lib/search"

describe 'RawToMzml' do
  before do
    @search = Search.new("#{File.dirname($0)}/../data/spectra/test_1", "human", "trypsin", :omssa => true, :xtandem => true, :tide => true, :mascot => true)
  end
  
  it 'takes an input file and runs OMSSA, X! Tandem, Tide, and Mascot search engines on it, both target and decoy' do
    @search.run
    
    Dir["#{File.dirname($0)}/../data/search/test_1-decoy_mascot.pep.xml"].first.isnt nil
    Dir["#{File.dirname($0)}/../data/search/test_1-decoy_tandem.pep.xml"].first.isnt nil
    Dir["#{File.dirname($0)}/../data/search/test_1-decoy_omssa.pep.xml"].first.isnt nil
    Dir["#{File.dirname($0)}/../data/search/test_1-decoy_tide.pep.xml"].first.isnt nil
    Dir["#{File.dirname($0)}/../data/search/test_1-target_mascot.pep.xml"].first.isnt nil
    Dir["#{File.dirname($0)}/../data/search/test_1-target_tandem.pep.xml"].first.isnt nil
    Dir["#{File.dirname($0)}/../data/search/test_1-target_omssa.pep.xml"].first.isnt nil
    Dir["#{File.dirname($0)}/../data/search/test_1-target_tide.pep.xml"].first.isnt nil
  end
end
