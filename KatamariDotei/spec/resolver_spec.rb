require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../lib/resolver"

Sample = Struct.new(:mzml, :mgfs, :searches, :percolator, :combined)

describe 'Resolver' do
  before do
    samples = {}
    samples["combined_1"] = Sample.new([], [], [], [], [%[#{File.expand_path(File.join(File.dirname(__FILE__), "..", "spec/test_files/combined_1.psms"))}]])
    @r1 = Resolver.new(samples)
    
    samples = {}
    samples["combined_2"] = Sample.new([], [], [], [], [%[#{File.expand_path(File.join(File.dirname(__FILE__), "..", "spec/test_files/combined_2.psms"))}]])
    @r2 = Resolver.new(samples)
    
    @peps1 = [["DDDD", ["PEP005", "PEP003", "PEP001"]], ["CCCC", ["PEP004"]], ["BBBB", ["PEP002"]], ["EEEE", ["PEP111"]]]
    @pros1 = [["PEP111", ["EEEE"]], ["PEP001", ["DDDD", "AAAA", "BBBB"]], ["PEP003", ["CCCC"]]]
    @peps2 = [["GVIVDKDFSHPQMPK", ["Q9BU08", "Q96GI1", "P48643", "B7ZAR1", "B4DZY9", "B4DZT5", "Q63ZY4", "B4DYC8", "B4DXI1", "B4DX08", "B4DE30", "B4DDU6", "A8K2X8"]], ["GPHHLDNSSPGPGSEAR", ["Q8WWM7-6", "Q8WWM7-5", "Q8WWM7-4", "Q8WWM7-3", "Q96HB1", "Q8WWM7", "A8K1R6"]], ["LVANLTYTLQLDGHR", ["P20701-2", "P20701", "B4DXB9", "B4E021", "B2RAL6"]], ["KGSLVAELSTIESSHR", ["Q9GZS0-2", "Q9GZS0", "Q4G115"]], ["GSPNTASAEATLPRWR", ["Q6PJG6-3", "Q6PJG6", "C9JY24"]], ["EIMQNGPVQAIMQVR", ["Q9UJW2-2", "Q9UJW2", "B1AQ11"]], ["ALLANQDSGEVQQDPK", ["Q9NP81", "B4DJM9"]], ["RGALLYMYCHSLTK", ["A6NDU8"]], ["AGPQSPSPGAPPAAKPARG", ["Q9H1Z9"]]]
    @pros2 = [["A6NDU8", ["RGALLYMYCHSLTK"]], ["Q9H1Z9", ["AGPQSPSPGAPPAAKPARG"]], ["A8K2X8", ["KGSLVAELSTIESSHR", "GVIVDKDFSHPQMPK"]], ["B4DXB9", ["LVANLTYTLQLDGHR", "ALLANQDSGEVQQDPK"]], ["Q63ZY4", ["GPHHLDNSSPGPGSEAR"]], ["Q6PJG6-3", ["GSPNTASAEATLPRWR"]], ["Q9UJW2-2", ["EIMQNGPVQAIMQVR"]]]
  end
  
  it 'Finds the minimum number of proteins and peptides' do
    peps, pros = @r1.resolve
    peps.is @peps1
    pros.is @pros1
    
    peps, pros = @r2.resolve
    peps.is @peps2
    pros.is @pros2
    puts @r1.prince_resolve
  end
end
