#!/usr/bin/ruby
#
# Checks application HAML files using haml tool
#
# It is much faster than find ... -exec haml {}...
#
require 'rubygems'
version = ">= 3.0"
gem 'haml', version
#load Gem.bin_path('haml', 'haml', version)
require 'haml'
require 'haml/exec'
require 'find'

PATH = 'src/app/views/'
puts "Checking HAML files in #{PATH}..."

Find.find(PATH) do |path|
  if FileTest.directory?(path)
    # ignore hidden dirs (.ssh etc)
    if File.basename(path)[0] == ?.
      Find.prune
    else
      next
    end
  else
    puts "Checking #{path}"
    opts = Haml::Exec::Haml.new(["-c", path])
    begin
      opts.parse
    rescue Exception => e
      $stderr.print "#{e.class}: " unless e.class == RuntimeError
        $stderr.puts "#{e.message}"
      exit 1
    end
  end
end

exit 0
