#!/usr/bin/ruby
# vim: ts=2:sw=2:et:
#
# Copyright © 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

require 'fileutils'

def command_exists?(command)
  ENV['PATH'].split(':').each {|folder| File.executable?("#{folder}/#{command}")}
end

def detect_terminal_size
  default_size = [80, 25]
  term_size = if (ENV['COLUMNS'] =~ /^\d+$/) && (ENV['LINES'] =~ /^\d+$/)
                [ENV['COLUMNS'].to_i, ENV['LINES'].to_i]
              elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && command_exists?('tput')
                [`tput cols`.to_i, `tput lines`.to_i]
              elsif STDIN.tty? && command_exists?('stty')
                `stty size`.scan(/\d+/).map { |s| s.to_i }.reverse
              else
                default_size
              end
  term_size.each_with_index { |val, i| term_size[i] = default_size[i] if val == 0 }
  term_size
rescue
  default_size
end

COLUMNS = detect_terminal_size[0]

# simple text wrapper for long lines (optparse does not handle long lines correctly)
def word_wrap(text, line_width = COLUMNS, indent = ' ' * 11)
  unstripped = text.split("\n").collect do |line|
    line.length > line_width ? line.strip.gsub(/(.{1,#{line_width}})(\s+|$)/, "#{indent}\\1\n").rstrip : line.strip
  end * "\n"
  unstripped.lstrip # fist line must not be indented
end

# same behavior as wrap function, but it removes (re-wraps) newlines first
def word_rewrap(text, line_width, indent)
  word_wrap(text.gsub(/\n/, ' '), line_width, indent)
end

def print_horizontal_line
  print '-' * COLUMNS; print "\n"
end

# Reading answer file, used both for the default answer file
# and for user files. The structure of the answer file is
#
# # The short description of the option.
# # Multiline synopsis of the option
# # with more details.
# option_name = option_value
#
def read_answer_file(filename)
  file = File.new(filename, "r")
  error = ''
  data = {}
  data_order = []
  $titles = {}
  docs = {}
  title = ''
  synopsis = ''
  while (line = file.gets)
    if line =~ /^\s*#/
      if title == ''
        title = line.gsub(/^\s*#\s*/, '').chop
      else
        synopsis.concat(line.gsub(/^\s*#\s*/, ''))
      end
      next
    end
    line = line.gsub(/\s+$/, '')
    if not line =~ /\S+/
      title = ''
      synopsis = ''
      next
    end
    if line =~ /^\s*(\w+)\s*=\s*(.*)/
      data[$1] = $2
      docs[$1] = synopsis
      data_order.push $1
      $titles[$1] = title.gsub(/\.\s*$/, '')
    else
      error.concat "Unsupported config line format [#{line}] in file [#{filename}]\n"
    end
    title = ''
    synopsis = ''
  end
  file.close
  return data, data_order, error, $titles, docs
end
