$vpath = "/home/jashi/pipeline/pipeline0.01/"

require 'spec/more'
require "#{$vpath}src/mzxml_to_other.rb"

describe 'MzXMLToOther' do
    before do
        @mztg = MzXMLToOther.new("mgf", "#{$vpath}data/043010_100430153139.mzXML", false)
        @mztd = MzXMLToOther.new("dta", "#{$vpath}data/043010_100430153139.mzXML", false)
        @mztgh = MzXMLToOther.new("mgf", "#{$vpath}data/043010_100430153139.mzXML", true)
    end

    it 'takes an mzXML file and outputs it in a different format' do
        @mztg.convert
        Dir["#{$vpath}data/043010_100430153139.mgf"].first.isnt nil
        
        @mztd.convert
        Dir["#{$vpath}data/043010_100430153139"].first.isnt nil
    end
    
    it 'can create a hardklor file' do
        @mztgh.convert
        Dir["#{$vpath}data/043010_100430153139.hardklor"].first.isnt nil
    end
end