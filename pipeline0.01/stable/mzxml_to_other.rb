require 'rubygems'
require "#{$path}ms-msrun/lib/ms/msrun"

class MzXMLToOther
    def initialize(type, file, output, hardklor)
        @type = type
        @file = file
        @output = output
        @hardklor = hardklor
    end

    def convert
        puts "\n----------------"
        puts "Transforming mzXML file to #{@type} format..."
        
        runHardklor if @hardklor
        
        if @type == "mgf"
            Ms::Msrun.open(@file) do |ms|
                file = @output
                file += ".mgf"
                File.new(file, "w+").close
                File.open(file, 'w') do |f|
                    f.puts ms.to_mgf() 
                end
            end
        else
            exec("/usr/local/src/tpp-4.3.1/build/linux/MzXML2Search #{@type} #{@file}") if fork == nil
            Process.wait
        end
    end
    
    private
    
    def runHardklor
        puts "Running Hardklor..."
        Dir.chdir("#{$path}hardklor/") do
            exec("./hardklor #{@file} #{@output}.hk") if fork == nil
            Process.wait
        end
    end
end
