desc 'Pretty print out all defined routes in match order, with names. Target specific controller with CONTROLLER=x.'

task :pretty_routes => :environment do
  all_routes = ENV['CONTROLLER'] ? ActionController::Routing::Routes.routes.select { |route| route.defaults[:controller] == ENV['CONTROLLER'] } : ActionController::Routing::Routes.routes
  routes = all_routes.collect do |route|
    reqs = route.requirements.empty? ? "" : route.requirements[:controller] + '#' + route.requirements[:action]
    {:name => route.name, :verb => route.verb, :path => route.path, :reqs => reqs}
  end
  if ENV['TEXT']
    filename = 'routes.txt'
    puts "Generating #{filename}"
    File.open(File.join(RAILS_ROOT, filename), "w") do |f|
      routes.each do |r|
        f.puts [r[:name], r[:verb], r[:path], r[:reqs]].compact.join(' | ')
      end
    end
  else
    filename = 'routes.html'
    puts "Generating #{filename}"
    File.open(File.join(RAILS_ROOT, filename), "w") do |f|
      f.puts "<html><head><title>Rails 3 Routes</title></head><body><table border=1>"
      f.puts "<tr><th>Name</th><th>Verb</th><th>Path</th><th>Requirements</th></tr>"
      routes.each do |r|
        f.puts "<tr><td>#{r[:name]}</td><td>#{r[:verb]}</td><td>#{r[:path]}</td><td>#{r[:reqs]}</td></tr>"
      end
      f.puts "</table></body></html>"
    end
  end
end
