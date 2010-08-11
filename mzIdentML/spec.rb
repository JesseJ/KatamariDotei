require 'spec/more'
require 'fileutils'
require "#{File.dirname($0)}/search2mzidentml.rb"
require 'mechanize'

describe 'PepXML2mzIdentML' do
  before do
    @dir = File.dirname($0)
#    @p2mm = Search2mzIdentML.new(PepXML.new("#{@dir}/test.pep.xml", "#{@dir}/../databases/uni_human_var_100517_fwd.fasta"))
#    @p2mo = Search2mzIdentML.new(PepXML.new("#{@dir}/test-omssa.pep.xml", "#{@dir}/../databases/uni_human_var_100517_fwd.fasta"))
#    @p2mt = Search2mzIdentML.new(PepXML.new("#{@dir}/test-tandem.pep.xml", "#{@dir}/../databases/uni_human_var_100517_fwd.fasta"))
#    @p2mi = Search2mzIdentML.new(PepXML.new("#{@dir}/test-tide.pep.xml", "#{@dir}/../databases/uni_human_var_100517_fwd.fasta"))
  end
  
  it 'takes a pepXML file and outputs an mzIdentML file' do
#    @p2mm.convert
#    @p2mo.convert
#    @p2mt.convert
#    @p2mi.convert
        
    mascot = File.open("#{@dir}/test.mzid")
    mascot_key = File.open("#{@dir}/mascot-key.mzid")
    
    tandem = File.open("#{@dir}/test-tandem.mzid")
    tandem_key = File.open("#{@dir}/tandem-key.mzid")
    
    tide = File.open("#{@dir}/test-tide.mzid")
    tide_key = File.open("#{@dir}/tide-key.mzid")
    
    omssa = File.open("#{@dir}/test-omssa.mzid")
    omssa_key = File.open("#{@dir}/omssa-key.mzid")
    
    FileUtils::cmp(mascot, mascot_key).is true
    FileUtils::cmp(tandem, tandem_key).is true
    FileUtils::cmp(tide, tide_key).is true
    FileUtils::cmp(omssa, omssa_key).is true
    
    agent = Mechanize.new {|agent| agent.user_agent_alias = 'Linux Firefox'}
    
    agent.get("http://www-bs2.informatik.uni-tuebingen.de/services/OpenMS/analysisXML/index.php") do |page|
#      form = page.forms.first
#      form.file_uploads.first.file_name = File.expand_path(mascot)
#      page = agent.submit(form, form.buttons.first)
      page = page.form_with(:method => 'POST') do |form|
        form.file_uploads.first.file_name = File.expand_path(mascot)
      end.submit

      p page
    end
  end
end


Bacon.summary_on_exit
