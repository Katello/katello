#!/usr/bin/ruby

require 'optparse'

default_options = {:dir => File.expand_path("../..", __FILE__)}

options = default_options.dup

parser = OptionParser.new do |opts|
  opts.banner = <<DESC
Find (and possibly fix) malformed gettext strings such as:

_("This is a malformed string with \#{interpolated_variable} within")
# should be _("This is a malformed string with %s within") % interpolated_variable

_("This is a malformed string with %s, and another %s") % [var1, var2]
# should be _("This is a malformed string with %{var1}, and another %{var2}") %
#              {:var1 => var1, :var2 => var2}

It exits with 0 unless some problems found
DESC

  opts.on("-d", "--dir DIR", "Directory with the source code") do |val|
    options[:dir] = val
  end

  opts.on("-i", "--interpolations", "Find malformed interpolations") do
    options[:interpolations] = true
  end

  opts.on("-m", "--multivars", "Find strings with more anonymous variables") do
    options[:multivars] = true
  end

  opts.on("-f", "--fix", "Try to fix the malformed strings in the source") do
    options[:fix] = true
  end
end

parser.parse!

malformed_strings = Hash.new { |h, k| h[k] = [] }

dir = options[:dir]
dir << '/' unless dir.end_with?('/')

Dir.glob(File.join(dir, "**", "*")).each do |file|
  next if File.directory?(file)
  next if File.symlink?(file)
  next if file.include?("/vendor/converge-ui/") # we skip converge-ui for now
  next if file.end_with?("check-gettext.rb") # we don't check this very file
  relative_file = file.sub(/^#{Regexp.escape(dir)}/, "")
  file_content = File.read(file)
  begin
  gettext_strings = file_content.scan(/(_\(".*?"\))(.*)$/).map do |(string, suffix)|
    if suffix.to_s.include?(".replace") # this is javascript and it uses different tool
      next
    end
    if suffix = suffix.to_s[/(\s*%\s*.*$)/]
      parts = suffix.split(/(\])/)
      suffix = parts.reduce("") {|s, p| s << p; break s if s.count("[") == s.count("]"); s}
    end
    [string, suffix]
  end.compact
  rescue ArgumentError => e
    next # we can't scan binary files, skipping
  end
  if options[:interpolations]
    found_strings = gettext_strings.find_all do |(s, suffix)|
      s =~ /#\{.*?\}/
    end
    malformed_strings[relative_file].concat(found_strings.map(&:first))
    found_strings.each do |(malformed, malformed_suffix)|
      puts "#{relative_file}: #{malformed}"
      if options[:fix]
        variables = malformed.scan(/#\{(.*?)\}/).map(&:first)
        fixed = malformed.gsub(/#\{.*?\}/,"%s")
        fixed << " % "
        if variables.size == 1
          fixed << variables.first
        else
          fixed << "["
          fixed << variables.join(", ")
          fixed << "]"
        end

        file_content.gsub!(malformed, fixed)
      end
    end
  end

  if options[:multivars]
    found_strings = gettext_strings.find_all do |(s, suffix)|
      s.scan(/%[a-z]/).size > 1
    end
    malformed_strings[relative_file].concat(found_strings)
    found_strings.each do |(malformed, malformed_suffix)|
      puts "#{relative_file}: #{malformed}#{malformed_suffix}"
      if options[:fix]
        if malformed_suffix =~ /\s*%\s*\[(.*)\]/
          array_vars = $1.split(",").map(&:strip)
          puts "Are this the variables used in the string?:"
          puts array_vars.inspect
          puts "[y/n]"
          if gets.chomp == "y"
            mapping = array_vars.reduce({}) do |h, var|
              puts "Write alias for #{var}"
              h.update(var => gets.chomp)
            end
            fixed, fixed_suffix = malformed.dup, []
            array_vars.each do |var|
              fixed.sub!(/%\w+/, "%{#{mapping[var]}}")
              fixed_suffix << ":#{mapping[var]} => #{var}"
            end
            fixed_suffix = " % {#{fixed_suffix.join(", ")}}"
            puts "Fixing to: #{fixed}#{fixed_suffix}"
            file_content.gsub!("#{malformed}#{malformed_suffix}", "#{fixed}#{fixed_suffix}")
          else
            puts "In that case you have to fix it manually"
          end
        else
          puts "This script is too dummy to solve this, please fix this manually"
        end
      end
    end
  end
  File.write(file, file_content) if options[:fix]
end

malformed_strings_count = malformed_strings.values.flatten(1).size
if malformed_strings_count == 0
  exit 0
else
  STDERR.puts("Found #{malformed_strings_count} malformed strings")
  exit 1
end
