# encoding: utf-8

# The Rakefile for Katello is really only useful for running
# string extraction. See the README in the locale directory for more
# information.
#
#
# This Rakefile rquires that the foreman code be checked out in a
# peer directory to katello.
#
require 'rubygems'
require 'rake'
require 'fileutils'

task :default => "gettext:find"

gem "puppet"
gem "facter"

PLUGIN_NAME = "katello"
ENGINE_DIR = File.expand_path('..', __FILE__)
FOREMAN_DIR = File.expand_path('../../foreman', __FILE__)

ENV['TEXTDOMAIN'] = PLUGIN_NAME
import "#{FOREMAN_DIR}/Rakefile" if File.exists? "#{FOREMAN_DIR}/Rakefile"
