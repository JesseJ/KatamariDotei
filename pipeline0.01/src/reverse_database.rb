require 'optparse'
require "#{File.dirname($0)}/../../ms-fasta/lib/ms/fasta.rb"

if ARGV.size != 2
    puts "usage: #{File.basename(__FILE__)} inputFile outputFile"
    exit
end


#This will reverse the given protein database so it can be used for decoy searches.
#Does some possibly unnecessary sequence text formatting
class ReverseDatabase
    def reverseDatabase(input, output)
        File.open("#{output}", 'w') do |out|
            fasta = Ms::Fasta.open("#{input}")
            fasta.each do |entry|
                out.print( ">" << entry.header.to_s << "\n" )
                reversedSequence = entry.sequence.reverse

                lines = (reversedSequence.length / 60)
                
                lines -= 1 if reversedSequence.length % 60 == 0
                
                lines.times do |i|
                    if (i < lines)
                        reversedSequence.insert((i + 1) * 60 + i,"\n")
                    end
                end
                
                out.print( reversedSequence << "\n" )
            end
        end
    end
end

rd = ReverseDatabase.new
rd.reverseDatabase(ARGV[0], ARGV[1])