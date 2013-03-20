require 'rubygems'

# Set up gems listed in the Gemfile.
if ENV['BUNDLE_GEMFILE']
  gemfile = ENV['BUNDLE_GEMFILE']
else
  gemfile = File.expand_path('../../Gemfile', __FILE__)
end

begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)
