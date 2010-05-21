class RawTomzXML
    def initialize(file, output)
        @file = file
        @output = output
    end
    
    def convert
        puts "\n----------------"
        puts "Transforming raw file to mzXML format..."
        exec("wine readw.exe --mzXML #{@file} #{@output}.mzXML 2>/dev/null") if fork == nil
        Process.wait
    end
end