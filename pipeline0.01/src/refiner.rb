require "#{$vpath}src/false_rate_discoverer.rb"

class Refiner
    def initialize(files, qValues, cutoff)
        @files = files
        @qValues = qValues
        @cutoff = cutoff
    end
    
    def refine
        puts "\n----------------"
        puts "Refining search..."
        
        doc = Nokogiri::XML(File.open(@files, "r"))
        doc.search("//search_hit").each do |node|
            #puts node.parent.parent#.xpath("search_score[@name=\"expect\"]//@value").to_s.to_f
            #puts getQValue(node.xpath("search_score[@name=\"expect\"]//@value").to_s.to_f)
            node.parent.parent.remove if getQValue(node.xpath("search_score[@name=\"expect\"]//@value").to_s.to_f).to_f < @cutoff
        end
        
        file = File.open("#{$vpath}data/refineTest.pep.xml", "w")
        file.puts doc
        file.close
    end
    
    def getQValue(value)
        @qValues.each do |pair|
            return pair[1] if pair[0].score == value
        end
        
        nil
    end
end