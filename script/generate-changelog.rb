#!/usr/bin/env ruby

require 'open3'
require 'json'
require 'restclient'
require 'English'

if ARGV.length < 2
  puts "Please provide a start and end tag to generate a changelog for."
  exit 0
end

def syscall(*cmd)
  stdout, _stderr, status = Open3.capture3(*cmd)
  status.success? && stdout.slice!(0..-(1 + $INPUT_RECORD_SEPARATOR.size)) # strip trailing eol
end

def issue_numbers(title)
  issues = []
  title.scan(/([\s\(\[,-]|^)(fixes|refs)[\s:]+(#\d+([\s,;&]+#\d+)*)(?=[[:punct:]]|\s|<|$)/i) do |match|
    action, refs = match[1].to_s.downcase, match[2]
    next if action.empty?
    issues = refs.scan(/#(\d+)/).collect { |m| m[0].to_i }
  end
  issues
end

def get_issue(number)
  site = 'http://projects.theforeman.org/'
  path = "issues/#{number}.json"
  resource = RestClient::Resource.new(site)
  JSON.parse(resource[path].get)['issue']
rescue RestClient::ResourceNotFound => e
  puts e
end

def generate_entry(entry)
  hash = entry[0, entry.index(" ")]
  issues = issue_numbers(entry)
  title = entry.sub(hash, '')

  dash = title.index(" - ")
  title = title[dash + 3..-1] if dash

  colon = title.index(": ") unless dash
  title = title[colon + 2..-1] if colon

  comma = title.index(", ") if !dash && !colon
  title = title[comma + 2..-1] if comma

  title_string = " * %{title} ("
  hash_string = "[%{hash}](http://github.com/katello/katello/commit/%{hash})"
  issue_string = "[#%{issue}](http://projects.theforeman.org/issues/%{issue})"

  list_item = title_string % {:title => title}

  issues.each do |issue_number|
    list_item += issue_string % {:issue => issue_number}
    list_item += ', '
  end

  list_item += hash_string % {:hash => hash}

  list_item += ')'

  issue = get_issue(issues.first) unless issues.empty?
  tracker = issue ? issue['tracker']['name'] : 'Bug'
  category = (issue && issue['category']) ? issue['category']['name'] : 'Other'

  if tracker == 'Bug'
    @bugs[category] = [] unless @bugs.key?(category)
    @bugs[category] << list_item
  elsif tracker == 'Feature'
    @features[category] = [] unless @features.key?(category)
    @features[category] << list_item
  end
end

def generate_entries(log)
  log = log.split("\n")
  log = log.select { |entry| !entry.start_with?(' Automatic commit') }
  log.collect do |entry|
    generate_entry(entry)
  end
end

# rubocop:disable MethodLength
def format_entries
  entry_string = "\n## Features \n"
  @features.each do |category, entries|
    if category != 'Other'
      entry_string += "\n### #{category}\n"

      entries.each do |entry|
        entry_string += "#{entry}\n"
      end
    end
  end

  if @features.key?('Other')
    entry_string += "\n### Other\n"
    @features['Other'].each do |entry|
      entry_string += "#{entry}\n"
    end
  end

  entry_string += "\n## Bug Fixes \n"
  @bugs.each do |category, entries|
    if category != 'Other'
      entry_string += "\n### #{category}\n"

      entries.each do |entry|
        entry_string += "#{entry}\n"
      end
    end
  end

  if @bugs.key?('Other')
    entry_string += "\n### Other\n"
    @bugs['Other'].each do |entry|
      entry_string += "#{entry}\n"
    end
  end

  entry_string
end

@features = {}
@bugs = {}

start_tag = ARGV[0]
end_tag = ARGV[1]
code_name = ARGV[2] if ARGV.length == 3

log = syscall("git log #{start_tag}...#{end_tag} --pretty=format:'%h %s' | grep -v Merge")
tag_date = syscall("git log -1 --format=%ai #{end_tag}").split(' ')[0]

generate_entries(log)
changelog = format_entries

File.rename('CHANGELOG.md', 'CHANGELOG.md.backup')
File.open('CHANGELOG.md', 'w') do |file|
  if code_name
    file.write("##{code_name} (#{end_tag} - #{tag_date}) \n")
  else
    file.write("##{end_tag} (#{tag_date}) \n")
  end
  file.write(changelog)

  File.open('CHANGELOG.md.backup', 'r') do |backup|
    file.write(backup.read)
  end
end

File.delete('CHANGELOG.md.backup')
