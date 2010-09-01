  
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
