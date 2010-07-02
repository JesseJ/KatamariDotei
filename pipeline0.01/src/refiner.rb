require "#{$path}false_rate_discoverer.rb"

#Is used to refine the input to search engines. A part of the iterative process of searching.
#Unfinished and non-working.
class Refiner
    def initialize(files, qValues, cutoff)
        @files = files
        (@qValues, garbage) = qValues.partition {|q| q[1] < cutoff}
        @cutoff = cutoff
    end
    
    def refine
        puts "\n----------------"
        puts "Refining search...\n"
        
        titles = []
        doc = Nokogiri::XML(IO.read(@files))
        
        doc.search("//search_hit").each do |node|
            titles << node.parent.parent.xpath("@spectrum")
            node.parent.parent.remove if getQValue(node.xpath("search_score[@name=\"expect\"]//@value").to_s.to_f) == true
        end
        
        file = File.open("#{$path}../data/refineTest.pep.xml", "w")
        file.puts doc
        file.close
    end
    
    def getQValue(value)
        @qValues.each do |pair|
            return true if pair[0].score == value
        end
        
        false
    end
end