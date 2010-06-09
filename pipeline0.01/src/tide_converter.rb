require 'nokogiri'

#Converts Tide output to pepXML.
#file: A string containing the location of the tide output file
#database: A string containing the location of the database
#enzyme: The name of the enzyme
class TideConverter
	def initialize(file, database, enzyme)
        @file = file
        @database = database
        @enzyme = enzyme
        
        temp = file.split("/")
    	@fileName = temp[temp.length - 1]
    end
    
    def convert
    	file = File.new("#{@file}.pep.xml", "w+")
    	tide = File.open("#{@file}.results", "r")
    	hits = []
    	data = []
    	
    	tide.each_line {|line| hits << line.split}
    	
    	#Sort by spectrum index
    	#hits.sort! {|x,y| x[0].to_i <=> y[0].to_i}
    	hits = hits.sort_by {|x| [x[0].to_i, x[2].to_i]}
    	
    	#Group by spectrum
    	i = 0
    	while i < hits.length
    		spectrum = []
    		hit = hits[i]
    		
    		#hit = [spectrum, pre_mass, charge, xCorr, peptide]
    		while i < hits.length && hits[i][0] == hit[0] && hits[i][2] == hit[2]
    			spectrum << hits[i]
    			i += 1
    		end
    		
    		data << spectrum.sort {|x,y| y[3].to_f <=> x[3].to_f}
    	end
    	
    	file.puts buildPepXML(data).to_xml
   		
    	tide.close
    	file.close
    end
    
    def buildPepXML(data)
    	time = Time.new
    	
    	builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
			xml.msms_pipeline_analysis(:date => time.strftime("%Y-%m-%dT%H:%M:%S"), :summary_xml => "#{@file}.pep.xml") {
				xml.msms_run_summary(:base_name => "#{@file}.pep.xml", :raw_data_type => "raw", :raw_data => ".mzXML") {
					xml.sample_enzyme(:name => @enzyme)
					xml.search_summary(:base_name => "#{@file}.pep.xml", :search_engine => "Tide") {
						xml.search_database(:local_path => @database)
						xml.enzymatic_search_constraint(:enzyme => @enzyme)
					}
					
					buildSpectrumQueries(xml, data)
				}
			}
		end
		
		builder
    end
    
    
    private
    
    def buildSpectrumQueries(xml, data)
    	data.each do |spectrum|
    		index = spectrum[0][0].to_s
    		
			xml.spectrum_query(:spectrum => @fileName + "." + index + "." + index + "." + spectrum[0][2].to_s, 
				:start_scan => "0", 
				:end_scan => "0", 
				:precursor_neutral_mass => (spectrum[0][1].to_f - 1.00727646677) * spectrum[0][2].to_f, 
				:assumed_charge => spectrum[0][2]) {
					xml.search_result {
						i = 1
						
						spectrum.each do |hit|
							xml.search_hit(:hit_rank => i, :peptide => hit[4], :calc_neutral_pep_mass => hit[1].to_f) {
							}
							
							i += 1
						end
					}
				}
		end
    end
end
