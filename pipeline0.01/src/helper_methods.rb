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
  doc = Nokogiri::XML(IO.read("#{$path}../data/taxonomy.xml"))
  return doc.xpath("//taxon[@label=\"#{type}\"]//file/@URL").to_s
end