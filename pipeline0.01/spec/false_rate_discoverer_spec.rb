$vpath = "/home/jashi/pipeline/pipeline0.01/"

require 'spec/more'
require "#{$vpath}src/false_rate_discoverer.rb"

describe 'FalseRateDiscoverer' do
  before do
    @target1 = [[0.20],[0.19],[0.18],[0.17],[0.15],[0.13],[0.12],[0.11]].map {|ar| Hit.new("target", ar[0], 2)}
    @fdr1 = FalseRateDiscoverer.new([["#{$vpath}spec/oneTest-forward.pep.xml", "#{$vpath}spec/oneTest-decoy.pep.xml"]])
    
    @target2 = [[0.20],[0.19],[0.18],[0.17],[0.15],[0.13],[0.12],[0.11]].map {|ar| Hit.new("target", ar[0], 2)}
    @target2 << Hit.new("target",0.8,3) << Hit.new("target",0.7,3) << Hit.new("target",0.6,3) << Hit.new("target",0.5,3)
    @fdr2 = FalseRateDiscoverer.new([["#{$vpath}spec/twoTest-forward.pep.xml", "#{$vpath}spec/twoTest-decoy.pep.xml"]])
  end
  
  it 'takes an array of arrays of two files and outputs the qvalues' do
    output = @fdr1.discoverFalseRate
    exp_qvalues = [0.0, 0.0, 0.0, 0.0, 1.0/5, 2.0/8, 2.0/8, 2.0/8]
    exp = @target1.zip(exp_qvalues).map {|h, qval| [h, qval]}
    (a, b) = [output, exp].map {|com| com.map {|v| [v.first, "%0.4f" % v.last]}}
    a.is b
    
    output = @fdr2.discoverFalseRate
    exp_qvalues = [0.0, 0.0, 0.0, 0.0, 1.0/5, 2.0/8, 2.0/8, 2.0/8, 0.0, 1.0/4, 1.0/4, 1.0/4]
    exp = @target2.zip(exp_qvalues).map {|h, qval| [h, qval]}
    (a, b) = [output, exp].map {|com| com.map {|v| [v.first, "%0.4f" % v.last]}}
    a.is b
  end
end

Bacon.summary_on_exit