require 'nokogiri'

# Converts Tide output to pepXML.
#
# @author Jesse Jashinsky (Aug 2010)
class TideConverter
  # @param [String] file the location of the tide output file
  # @param [String] database the location of the database
  # @param [String] enzyme the name of the enzyme
  def initialize(file, database, enzyme)
    @file = file
    @database = database
    @enzyme = enzyme
    @fileName = file.split("/")[-1]
  end
  
  # Converts the file to pepXML.
  def convert
    file = File.new("#{@file}.pep.xml", "w+")
    tide = File.open("#{@file}.results", "r")
    hits = []
    data = []
    
    # Parse the file
    tide.each_line {|line| hits << line.split}
    
    # Sort by spectrum index
    hits = hits.sort_by {|x| [x[0].to_i, x[2].to_i]}
    	
    # Group by spectrum
    i = 0
    while i < hits.length
      spectrum = []
      hit = hits[i]
    		
      # hit = [spectrum, pre_mass, charge, xCorr, peptide]
      while i < hits.length && hits[i][0] == hit[0] && hits[i][2] == hit[2]
    	  spectrum << hits[i]
    	  i += 1
      end
      
      data << spectrum.sort {|x,y| y[3].to_f <=> x[3].to_f}
    end
    
    # Create the pepXML file
    file.puts buildPepXML(data).to_xml
   	
    tide.close
    file.close
  end
  
  
  private
  
  # Builds the pepXML file.
  #
  # @param [Array] data an array of spectrums
  # @return [Nokogiri] the Nokogiri builder object
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
  
  # Builds the spectrum queries of the pepXML file.
  #
  # @param [Nokogiri] xml the object to build on
  # @param [Array] data an array of spectrums
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
                xml.search_score(:name => "xcorr", :value => hit[3])
              }
							
              i += 1
            end
          }
        }
    end
  end
end
