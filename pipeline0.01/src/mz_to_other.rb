require 'rubygems'
require "ms/msrun"

#Converts mzXML files to a different format.
class MzToOther
  #type == The extension type, e.g. mgf
  #file == A string containing the file location
  #hardklor == true or false, whether or not to run Hardklor. Doesn't work with mzML.
  def initialize(type, file, hardklor)
    @type = type
    @file = file
    @hardklor = hardklor
  end
  
  #Converts file into type. Determines whether to run convert_mzXML or convert_mzML
  #based on the extension of file.
  def convert
    puts "\n----------------"
    
    if @file.downcase.include? ".mzxml"
      puts "Transforming mzXML file to #{@type} format..."
      convert_mzXML
    elsif @file.downcase.include? ".mzml"
      puts "Transforming mzML file to #{@type} format..."
      convert_mzML
    end
  end
  
  def convert_mzXML
    runHardklor if @hardklor
    
    if @type == "mgf" || @type == "ms2"
      Ms::Msrun.open(@file) do |ms|
        file = @file.chomp(".mzXML") + ".#{@type}"
        File.open(file, 'w') do |f|
          f.puts eval "ms.to_#{@type}"  #This is a dynamic method call.
        end
      end
    else
      system("/usr/local/src/tpp-4.3.1/build/linux/MzXML2Search -#{@type} #{@file}")
    end
  end
  
  def convert_mzML
    Ms::Msrun.open(@file) do |ms|
      file = @file.chomp(".mzML") + ".#{@type}"
      File.open(file, 'w') do |f|
        f.puts eval "ms.to_#{@type}"
      end
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
