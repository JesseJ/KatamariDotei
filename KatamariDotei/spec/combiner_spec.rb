require "#{File.dirname($0)}/spec_helper"
require "#{File.dirname($0)}/../lib/combiner"

describe 'Combiner' do
  before do
    path = "#{File.dirname($0)}/test_files/"
    files1 = ["#{path}test_1_omssa.psms", "#{path}test_1_tandem.psms", "#{path}test_1_tide.psms", "#{path}test_1_mascot.psms"]
    
    @c1 = Combiner.new(files1, "test", "1")
  end
  
  it 'Combines multiple .psms files into one .psms file' do
    @c1.combine
    FileUtils::cmp(File.open("#{File.dirname($0)}/../data/results/test_combined_1.psms", "r"), File.open("#{File.dirname($0)}/test_files/test_combined_1-key.psms", "r")).is true
  end
end
