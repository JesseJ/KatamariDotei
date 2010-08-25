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

# Performs all the necessary formatting of databases for the Pipeline.
#
# @author Jesse Jashinsky (Aug 2010)
# @todo Add function to take care of updating taxonomy.xml and creation of the reverse folder if none exists. Is it possible to automate the adding of the Mascot databases?
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
  end
end

DatabaseFormatter.new(ARGV[0]).formatDatabase
