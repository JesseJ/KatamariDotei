require 'spec/more'
require 'fileutils'
require 'nokogiri'

#These need to be set since we're not running it from pipeline.rb
$path = "#{File.dirname($0)}/../lib/"  
$config = Nokogiri::XML(IO.read("#{$path}../../config.xml"))

Bacon.summary_on_exit