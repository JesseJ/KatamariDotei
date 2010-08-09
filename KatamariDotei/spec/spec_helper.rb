require 'spec/more'
require 'fileutils'
require 'nokogiri'

#These need to be set since we're not running it from pipeline.rb
$path = "#{File.expand_path(File.dirname(__FILE__) + "/../lib/")}/"
$: << $path
$config = Nokogiri::XML(IO.read("#{$path}../../config.xml"))

Bacon.summary_on_exit