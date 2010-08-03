$path = "#{File.dirname($0)}/../lib/"  #This needs to be set since we're not running it from pipeline.rb

require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../lib/resolver"

describe 'Resolver' do
  before do
    @r1 = Resolver.new("/home/jashi/pipeline/KatamariDotei/spec/combined_1.psms")
    @r2 = Resolver.new("/home/jashi/pipeline/KatamariDotei/data/results/combined_1.psms")
    @peps1 = [["DDDD", ["PEP005", "PEP003", "PEP001"]], ["CCCC", ["PEP004"]], ["BBBB", ["PEP002"]], ["EEEE", ["PEP111"]]]
    @pros1 = [["PEP111", ["EEEE"]], ["PEP001", ["DDDD", "AAAA", "BBBB"]], ["PEP003", ["CCCC"]]]
  end
  
  it 'Finds the minimum number of proteins and peptides' do
    peps, pros = @r1.resolve
    peps.is @peps1
    pros.is @pros1
  end
end
