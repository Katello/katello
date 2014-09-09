#!/usr/bin/env ruby

require 'open3'

def syscall(*cmd)
  stdout, _stderr, status = Open3.capture3(*cmd)
  status.success? && stdout.slice!(0..-(1 + $/.size)) # strip trailing eol
end

log = syscall("git log --pretty=format:'%h %s XX %aN <%cE>' | grep -v Merge")

contributors = log.split("\n").collect do |entry|
  entry.split('XX')[1].strip
end
contributors.uniq!
contributors.sort!

File.open('CONTRIBUTORS', 'w') do |file|
  file.puts('Contributors')

  contributors.each do |entry|
    file.puts(entry)
  end
end
