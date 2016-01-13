Dir["#{File.expand_path('../repository_types', __FILE__)}/*.rb"].each do |file|
  require file
end
