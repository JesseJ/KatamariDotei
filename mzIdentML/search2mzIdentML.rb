require "#{File.dirname($0)}/pepxml.rb"
require 'nokogiri'

#Creates an mzIdentML file from a file type created by a search engine, using the format classes such as PepXML.
#Takes a Format object
class Search2mzIdentML
	def initialize(format)
		@format = format
	end
	
	def convert
		file = createFile
		
		builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
			xml.mzIdentML(:id => "",
				:version => "1.0.0",
				'xsi:schemaLocation' => "http://psidev.info/psi/pi/mzIdentML/1.0 http://jp1.chem.byu.edu/mascot/xmlns/schema/mzIdentML/mzIdentML1.0.0.xsd",
				'xmlns' => "http://psidev.info/psi/pi/mzIdentML/1.0",
				'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
				:creationDate => @format.date) {
					createCVList(xml)
					provider(xml)
					sequenceCollection(xml)
					analysisCollection(xml)
					analysisProtocolCollection(xml)
			}
		end
		
		file.puts builder.to_xml
		file.close
	end
	
	private
	
	def createFile
		if @format.type == "pepxml"
			return File.new("#{@format.file.chomp('.pep.xml')}-test.mzid", "w+")
		end
	end
	
	def createCVList(xml)
		xml.cvList {
			xml.cv(:id => "PSI-MS", :fullName => "Proteomics Standards Initiative Mass Spectrometry Vocabularies", :URI => "http://psidev.cvs.sourceforge.net/viewvc/*checkout*/psidev/psi/psi-ms/mzML/controlledVocabulary/psi-ms.obo", :version => "2.32.0")
			xml.cv(:id => "UNIMOD", :fullName => "UNIMOD", :URI => "http://www.unimod.org/obo/unimod.obo")
			xml.cv(:id => "UO", :fullName => "UNIT-ONTOLOGY", :URI => "http://obo.cvs.sourceforge.net/*checkout*/obo/obo/ontology/phenotype/unit.obo")
		}
	end
	
	def provider(xml)
		xml.Provider(:Software_ref => "search2mzIdentML.rb", :id => "PROVIDER") {
			xml.ContactRole(:Contact_ref => "PERSON_DOC_OWNER") {
				xml.role {
					xml.cvParam(:accession => "MS:1001271", :name => "researcher", :cvRef => "PSI-MS")
				}
			}
		}
	end
	
	def sequenceCollection(xml)
		xml.SequenceCollection {
			dBSequences(xml)
			peptides(xml)
		}
	end
	
	def dBSequences(xml)
		proteins = @format.proteins
		proteins.each do |protein|
			xml.DBSequence(:id => "DBSeq_1_#{protein[0]}", :SearchDatabase_ref => @format.databaseName, :accession => protein[0]) {
				xml.cvParam(:accession => "MS:1001088", :name => "protein description", :cvRef => "PSI-MS", :value => protein[1])
			}
		end
	end
	
	def peptides(xml)
		peptides = @format.peptides
		j = 1
		i = 1
		peptides.each do |peptide|
			xml.Peptide(:id => "#peptide_#{j}_#{i}") {
				xml.peptideSequence peptide
			}
			
			i += 1
			if i == 11
				j += 1
				i = 1
			end
		end
	end
	
	def analysisCollection(xml)
		xml.AnalysisCollection {
			xml.SpectrumIdentification(:id => "SI", :SpectrumIdentificationProtocol_ref => "SIP", :SpectrumIdentificationList_ref => "SIL_1", :activityDate => @format.date) {
				xml.InputSpectra(:SpectraData_ref => "SD_1")
				xml.SearchDatabase(:SearchDatabase_ref => @format.databaseName)
			}
		}
	end
	
	def analysisProtocolCollection(xml)
		xml.AnalysisProtocolCollection {
		}
	end
	
	def SpectrumIdentificationProtocol(xml)
	end
	
	def dataCollection(xml)
		xml.dataCollection
	end
end