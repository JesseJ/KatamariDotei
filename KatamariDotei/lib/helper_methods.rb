#Methods that are needed by different classes.

# Prevents "no process" error. Simply loops and waits for all processes to finish, then once it waits
# on a nonexistent process the rescue quietly catches the error, and things proceed as normal.
def waitForAllProcesses
  begin
    Process.wait while true

  rescue SystemCallError
    #No need to do anything here, just go
  end
end

# Prevents "no process" error. Waits on a specific process, but if the process is already finished, then the error is quietly rescued.
#
# @param [Number] pid the pid, or Process ID
def waitForProcess(pid)
  begin
    waitpid(pid, 0)

  rescue SystemCallError
  end
end

# Obtains the file location of the FASTA database from the taxonomy file.
#
# @param [String] type the type of database, e.g. "human" or "mouse"
def extractDatabase(type)
  Nokogiri::XML(IO.read("#{$path}../../databases/taxonomy.xml")).xpath("//taxon[@label=\"#{type}\"]//file/@URL").to_s
end

# Converts a string that represents true or false into an actual true or false value.
#
# @return [Boolean] true if the string s is true, false otherwise.
def s_true(s)
  s = s.strip.downcase
  (s == "t") || (s == "true")
end

# Refactored method for the xml config file.
#
# @param [String] path an xpath string
# @return [String] the config value
def config_value(path)
  $config.xpath(path).to_s
end
