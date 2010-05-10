require 'nokogiri'
require "#{$path}ms-error_rate/lib/ms/error_rate/decoy.rb"
require "#{$path}ms-error_rate/lib/ms/error_rate/qvalue.rb"

#:type => "target" or "decoy"
#:score => The score of the hit
#:charge => The charge of the hit
Hit = Struct.new(:type, :score, :charge)

#Expects an array of arrays of two files, first forward, second decoy. [[for-file1, dec-file2], [for-file3, dec-file4]]
class FalseRateDiscoverer
    def initialize(files)
        @files = files
    end
    
    def discoverFalseRate
        puts "\n----------------"
        puts "Finding FDR..."
        
        @files.each do |files|
            targetArr = []
            decoyArr = []
            version = 0
            
            files.each do |file|
                doc = Nokogiri::XML(File.open(file))
                #Obtains the score and charge values from the pepXML file. The expect score is used, and values are taken only where hit_rank=1
                scoresAndCharges = doc.xpath("//search_hit[@hit_rank=\"1\"]//search_score[@name=\"expect\"]/@value|//spectrum_query/@assumed_charge")
                
                i = 0
                while i < scoresAndCharges.length
                    if version == 0
                        targetArr << Hit.new("target", scoresAndCharges[i+1].to_s.to_f, scoresAndCharges[i].to_s.to_i)
                    else
                        decoyArr << Hit.new("decoy", scoresAndCharges[i+1].to_s.to_f, scoresAndCharges[i].to_s.to_i)
                    end
                    
                    i += 2
                end

                version += 1
            end
            
            qValues = Ms::ErrorRate::Qvalue.target_decoy_qvalues(targetArr, decoyArr, :z_together => true)
            precision = Ms::ErrorRate::Decoy.precision(targetArr.length, decoyArr.length)
            
            all = (targetArr + decoyArr).sort_by {|h| [h.charge, h.score, h.type]}
            
            i = 0
            j = 0
            all.each do |hit|
                i += 1
                if hit.type == "decoy"
                    j += 1
                    i -= 1
                    #puts j.to_f / i.to_f
                end
            end
            
            return qValues
        end
    end
end