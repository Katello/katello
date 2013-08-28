path = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH << path unless $LOAD_PATH.include? path

require 'katello/load_configuration'

require 'ninesixty'
