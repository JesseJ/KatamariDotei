require 'rubygems'
require "ms/msrun"

# Converts mzXML files to a different format.
#
# @author Jesse Jashinsky (Aug 2010)
class MzmlToOther
  # @param [String] type the type to convert to, e.g. mgf or ms2
  # @param [String] the location of the mzML file
  # @param [Boolean] hardklor whether or not to run Hardklor. Doesn't work with mzML.
  def initialize(type, file, run, hardklor)
    @type = type
    @file = file
    @hardklor = hardklor
    @run = run
  end
  
  # Converts the mzML file into the given type. Determines whether to run convert_mzXML or convert_mzML
  # based on the extension of file.
  #
  # @return [String] the location of the new file
  def convert
    puts "\n--------------------------------"
    puts "Transforming #{File.extname(@file)} file to .#{@type} format..."
    
    runHardklor if @hardklor && @file.downcase.include?(".mzxml")
    
    if @type == "mgf" || @type == "ms2"
      Ms::Msrun.open(@file) do |ms|
        file = @file.chomp(File.extname(@file)) + "_#{@run}.#{@type}"
        File.open(file, 'w') do |f|
          f.puts eval("ms.to_#{@type}")
        end
        
        return file
      end
    else
      # If ms-msrun can't do it, then this might. Do something here to include run number. Doesn't work with Refiner, so
      # this is probably pointless to even have.
      #
      # And why do we run our own code to transform mzML instead of TPP?
      #   1) Prince said so
      #   2) I hate the TPP. The people who put that together don't deserve to be called programmers. I mean, come on! Methods
      #      should never be longer than 100 lines of code, yet they've got methods that are over 1000 lines of code! Ack! It
      #      just makes my skin crawl!
      system("/usr/local/src/tpp-4.3.1/build/linux/MzXML2Search -#{@type} #{@file}")
    end
  end
  
  
  private
  
  # Optional. Currently, nothing is done with Hardklor output.
  def runHardklor
    puts "Running Hardklor..."
    Dir.chdir("#{$path}../../hardklor/") do  #Hardklor won't work unless it's run from its directory. Lame.
      
      outputFile = @file.chomp(File.extname(@file))
      options = config_value("//Hardklor/@commandLine")
      exec("./hardklor #{@file} #{outputFile}.hk #{options}") if fork == nil
      Process.wait
    end
  end
end
