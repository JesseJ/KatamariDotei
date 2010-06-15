#Methods to be used by other classes for concurrency

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