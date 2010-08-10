#!/usr/bin/ruby

$path = "#{File.dirname($0)}/../lib/"

require "#{$path}/support/reverse_database.rb"
require 'rubygems'
require 'amalgalite'

if ARGV.size != 1
    puts "usage: #{File.basename(__FILE__)} inputFile"
    puts "inputFile: The name of the file in the databases folder, e.g. uni_human_var_100517.fasta"
    exit
end

#Performs all the necessary formatting of databases for the Pipeline.
class DatabaseFormatter
  #fileName == The name of the file in the databases folder
  def initialize(fileName)
    @fileName = fileName
  end
  
  #Performs all the formatting.
  def formatDatabase
    puts "Creating reversed database..."
    targetDatabase = "#{$path}../../databases/#{@fileName}"
    decoyDatabase = "#{$path}../../databases/reverse/#{@fileName}.reverse"
    ReverseDatabase.new(targetDatabase, decoyDatabase).reverseDatabase
    
    puts "Formatting databases for OMSSA..."
    exec("formatdb -p T -i #{targetDatabase}") if fork == nil
    exec("formatdb -p T -i #{decoyDatabase}") if fork == nil
    
    puts "Creating yaml files..."
    exec("#{$path}../../ms-error_rate/bin/fasta_to_peptide_centric_db.rb #{targetDatabase}") if fork == nil
    exec("#{$path}../../ms-error_rate/bin/fasta_to_peptide_centric_db.rb #{decoyDatabase}") if fork == nil
    
    begin
      Process.wait while true
  
    rescue SystemCallError
    end
    
#    puts "Creating sqlite databases. You should go do something else, because this will take a while."
#    create_database(targetDatabase.chomp("fasta"))
#    create_database(targetDatabase.chomp("fasta.reverse"))
  end
  
  def create_database(name)
    array = []
    
    File.open(name + "yml", "r").each_line do |line|
      parts = line.split(": ")
      array << [parts[0], parts[1]]
    end
    
    db = Amalgalite::Database.new("#{name}db")
    db.execute("CREATE TABLE peps(peptide, proteins)")
#    array.each {|x| db.execute("INSERT INTO peps(peptide, proteins) VALUES('#{x[0]}', '#{x[1]}')"); p x}
    
    db.prepare("INSERT INTO peps(peptide, proteins) VALUES(?, ?)") do |stmt|
      array.each do |x|
        p x
        stmt.execute(x[0], x[1])
      end
    end

  end
end

DatabaseFormatter.new(ARGV[0]).formatDatabase
