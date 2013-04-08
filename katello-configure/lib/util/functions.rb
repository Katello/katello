#!/usr/bin/ruby
# vim: ts=2:sw=2:et:
#
# Copyright 2013 Red Hat, Inc.
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

# error codes for exit_with function
ERROR_CODES = {
  :success => 0,
  :general => 1,
  :default_option_error => 2,
  :answer_missing => 3,
  :answer_parsing_error => 4,
  :answer_unknown_option => 5,
  :error_executing_puppet => 6,
  :hostname_error => 7,
  :not_root => 8,
  :java_error => 9,
  :unknown => 127,
}

# Terminate script with error code from ERROR_CODES hash
def exit_with(code = :unknown)
  code = ERROR_CODES[code.to_sym] || ERROR_CODES[:unknown]
  exit code
end

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

# Reading options format file, that describe what options are required
# and the allow optin values format described by regular expressions
# The structure of the answer file is
#
# # The short description of the option.
# option_name is_option_mandatory regular_expression
#
def read_options_format(filename)
  file = File.new(filename, "r")
  error = ''
  mandatory = {}
  regex = {}
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
    if line =~ /^\s*(\S+)\s+(true|false)\s+(\S*)$/
      mandatory[$1] = 'true' == $2
      regex[$1] = $3
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
  return mandatory, regex, data_order, error, $titles, docs
end

# The user answer file can only use (override) options that
# were already defined in the default answer file. This function
# checks that and returns false when there is a problem.
def check_options_against_default(final_options, default_options)
	result = true 
	final_options.keys.each do |key|
		if not default_options.has_key?(key)
			$stderr.puts "Unknown option [#{key}] in the answer file"
			result = false
		end
	end
  result
end

def _get_valid_option_value(option, defaults, finals)
  if finals.include?(option)
    return finals[option]
  end
  return defaults[option]
end

def _is_option_true(option_value)
  if option_value.nil?
    return false
  end
  return (option_value.match(/(true|yes|y|1)$/i) != nil)
end

def _read_password()
  stty_orig_val = %x( stty -g )
  system("stty -echo")
  input = STDIN.gets
  system("stty #{stty_orig_val}")
  puts
  return input
end

def _request_option_interactively(param, title, regex, default_value, non_interactive_value)
  default_value_ok = default_value.to_s() =~ Regexp.new(regex)
  if non_interactive_value
    if default_value.nil? or not default_value_ok
      $stderr.puts "Option: [#{title} (--#{param.gsub("_", "-")})] not correctly specified."
      exit 7
    else
      return default_value
    end
  end

  read_password = title.include?("password")
  while true
    if read_password
      while true
        print "Enter #{title}: "
        input = _read_password()
        print "Verify #{title}: "
        input2 = _read_password()
        if (input == input2)
          break
        end
        puts "Passwords do not match. Please, try again."
      end
    else
      default_draft = " [ #{default_value} ]" if default_value_ok
      print "Enter #{title}#{default_draft}: "
      input = STDIN.gets.strip
      if input.empty? and default_value_ok
        input = default_value
      end
    end
    if input.to_s() =~ Regexp.new(regex)
      return input
    end
    puts "Your entry has to match regular expression: /#{regex}/"
  end
end

# Prints a warning if FQDN is not set, returns error when
# localhost or hostname cannot be resolved (/etc/hosts entry is missing).
def check_hostname
  hostname = Socket.gethostname
  Socket.gethostbyname hostname
  Socket.gethostbyname 'localhost'
  $stderr.puts "WARNING: FQDN is not set!" unless hostname.index '.'
rescue SocketError => e
  puts "Error"
  $stderr.puts "Unable to resolve '#{hostname}' or 'localhost'. Check your DNS and /etc/hosts settings."
  exit_with :hostname_error
end


# remove option from $final_options (and order) hashes (and optionally move
# it to the temporary hash (used for dangerous options)
def remove_option!(default_options_order, final_options, name, temp_options = nil)
  if final_options.has_key? name
    temp_options[name] = $final_options[name] if temp_options
    final_options.delete(name)
    default_options_order.delete(name)
  end
end

def check_root_id(prog_name = $0)
  unless Process.uid == 0
    $stderr.puts "You must run #{prog_name} as root"
    exit_with :not_root
  end
end


# If there was an answer file specified, we parse it.
def parse_answer_option(answer_file, default_options)
  final_options = {}
  if answer_file != nil
    if not File.file?(answer_file)
      $stderr.puts "Answer file [#{answer_file}] does not seem to exist"
      exit_with :answer_missing
    end
    final_options, __unused, error = read_answer_file(answer_file)
    if error != ''
      $stderr.puts error
      exit_with :answer_parsing_error
    end

    unless check_options_against_default(final_options, default_options)
      exit_with :answer_unknown_option
    end
  end
  return final_options
end

def display_resulting_answer_file(default_options_order, final_options)
  default_options_order.each do |key|
    if final_options.has_key?(key)
      puts key + ' = ' + final_options[key]
    end
  end
end

def create_answer_file(result_config_path, final_options, default_options_order, titles)
  orig_umask = File.umask(077)
  begin
    File.unlink(result_config_path)
  rescue
  end
  result_config = IO.open(IO::sysopen(result_config_path, Fcntl::O_WRONLY | Fcntl::O_EXCL | Fcntl::O_CREAT))
  default_options_order.each do |key|
    if final_options.has_key?(key)
      result_config.syswrite('# ' + (titles[key] || key) + "\n" + key + ' = ' + final_options[key] + "\n\n")
    end
  end
  result_config.close
  File.umask(orig_umask)
end

# additional temporary file which is also used (but deleted afterwards)
def create_temp_config_file(temp_options)
  orig_umask = File.umask(077)
  temp_config_path = '/dev/null'
  Tempfile.open("katello-configure-temp") do |temp_config|
    temp_config_path = temp_config.path
    $temp_options.each_pair do |key, value|
      temp_config.syswrite("#{key}=#{value}\n")
    end
  end
  File.umask(orig_umask)
  return temp_config_path
end

def main_puppet(puppet_cmd, nobars, default_progressbar_title, puppet_logfile_filename, puppet_logfile_aprox_size, debug_stdout, commands_by_logfiles, puppet_in)
  puppet_logfile = IO.open(IO::sysopen(puppet_logfile_filename, Fcntl::O_WRONLY | Fcntl::O_EXCL | Fcntl::O_CREAT))
  puts "The top-level log file is [#{puppet_logfile_filename}]"
  seen_err = false
  ENV['LC_ALL'] = 'C'
  begin
    IO.popen("#{puppet_cmd} 2>&1", 'w+') do |f|
      f.puts puppet_in
      f.close_write
      processing_logfile = nil
      t = nil
      progress_bar = nobars ? nil : ProgressBar.create(:title => default_progressbar_title, :total => puppet_logfile_aprox_size, :smoothing => 0.6)
      while line = f.gets do
        time = Time.now.strftime("%y%m%d-%H:%M:%S ")
        puppet_logfile.syswrite(time + line.gsub(/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]/, ''))
        puts "Got " + line if ENV['KATELLO_CONFIGURE_DEBUG']
        if nobars
          if line =~ /debug:/
            puts line if debug_stdout
          else
            puts line
          end
        else
          progress_bar.increment
          if processing_logfile != nil
            if line =~ /notice:.*executed successfully/
              processing_logfile = nil
            elsif line =~ /err:/
              puts "\n  Failed, please check [#{processing_logfile}]\n  Report errors using # katello-debug tool."
              processing_logfile = nil
              seen_err = true
            end
          elsif line =~ /err:/
            print line
            seen_err = true
          end
          if line =~ /debug: Executing \'(.+)/
            line_rest = $1
            commands_by_logfiles.keys.each do |logfile|
              if line_rest.index(logfile) != nil
                processing_logfile = logfile
                progress_bar.title = commands_by_logfiles[logfile][0]
              end
            end
          end
        end
      end
      if not nobars
        progress_bar.title = default_progressbar_title
        progress_bar.finish
      end
      puts "\n"
    end
  rescue => e
    $stderr.puts 'Error: ' + e.message
    seen_err = true
  end
  puppet_logfile.close

  if seen_err
    exit_with :error_executing_puppet
  end
end
