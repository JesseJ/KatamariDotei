require 'rubygems'
require "ms/msrun"

#Converts mzXML files to a different format.
class MzXMLToOther
  def initialize(type, file, hardklor)
    @type = type
    @file = file
    @hardklor = hardklor
  end

  def convert
    puts "\n----------------"
    puts "Transforming mzXML file to #{@type} format..."
        
    runHardklor if @hardklor
        
    #For mgf files, Prince's to_mgf method is used. Why? Because we can.
    if @type == "mgf"
      Ms::Msrun.open(@file) do |ms|
        file = @file.chomp(".mzXML")
        file += ".mgf"
        File.new(file, "w+").close
        File.open(file, 'w') do |f|
            f.puts ms.to_mgf() 
          end
        end
      else
        exec("/usr/local/src/tpp-4.3.1/build/linux/MzXML2Search -#{@type} #{@file}") if fork == nil
        Process.wait
    end
  end
    
  private
    
  #Optional. Currently, nothing is done with Hardklor output.
  def runHardklor
    puts "Running Hardklor..."
    Dir.chdir("#{$path}../../hardklor/") do
      outputFile = @file.chomp(".mzXML")
      exec("./hardklor #{@file} #{outputFile}.hk") if fork == nil
      Process.wait
    end
  end
end
