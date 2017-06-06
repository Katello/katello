desc "Create config files based on sample ones"
task :configuration do
  Dir.entries('config/').select { |f| f =~ /.+-sample.+/ }.each do |f| 
    cp "config/#{f}", "config/#{f[/(.+)-sample.yml/, 1]}.yml"
  end
end