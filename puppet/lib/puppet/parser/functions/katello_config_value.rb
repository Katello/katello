module Puppet::Parser::Functions
  config_paths = Array.new()
  default_path = __FILE__.gsub(/^(.+)\/[^\/]+\/lib\/.*$/, '\1') + '/default-answer-file'
  if File.file?(default_path)
    config_paths.push(default_path)
  end
  if ENV['KATELLO_ANSWER_FILE'] and File.file?(ENV['KATELLO_ANSWER_FILE'])
    config_paths.push(ENV['KATELLO_ANSWER_FILE'])
  end
  data = Hash.new
  config_paths.each do |filename|
    file = File.new(filename, "r")
    while (line = file.gets)
      if line =~ /^\s*#/
        next
      end
      line = line.gsub(/\s+$/, '')
      if not line =~ /\S+/
        next
      end
      if line =~ /^\s*(\w+)\s*=\s*(.*)/
        data[$1] = $2
      else
        puts "Unsupported config line #{line} in file #{filename}"
      end
    end
    file.close
  end

  newfunction(:katello_config_value, :type => :rvalue) do |args|
    return data[args[0]]
  end
end
