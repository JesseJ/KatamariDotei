#Methods that are needed by different classes.

#Prevents "no process" error
def waitForAllProcesses
  begin
    Process.wait while true

  rescue SystemCallError
    #No need to do anything here, just go
  end
end

#Prevents "no process" error
def waitForProcess(pid)
  begin
    waitpid(pid, 0)

  rescue SystemCallError
  end
end

#Obtains the file location based on the database type, such as "human" or "mouse"
def extractDatabase(type)
  Nokogiri::XML(IO.read("#{$path}../../databases/taxonomy.xml")).xpath("//taxon[@label=\"#{type}\"]//file/@URL").to_s
end

# Returns true if the string s is true, false otherwise.
def s_true(s)
  s = s.strip.downcase
  
  return true if s == "t" || s == "true"
  false
end

# Takes an xpath string and returns the config value
def config_value(path)
  $config.xpath(path).to_s
end
