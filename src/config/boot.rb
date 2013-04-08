require 'rubygems'

path = File.expand_path("../lib", File.dirname(__FILE__))
$LOAD_PATH << path unless $LOAD_PATH.include? path
require 'katello/load_configuration'

# Set up gems listed in the Gemfile.
if ENV['BUNDLE_GEMFILE']
  gemfile = ENV['BUNDLE_GEMFILE']
else
  gemfile = File.expand_path('../../Gemfile', __FILE__)
end

begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  if Katello.early_config.use_bundler
    require 'bundler'
    Bundler.setup
  end
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)
