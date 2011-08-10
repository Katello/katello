desc 'Pretty print out all defined routes in match order, with names. Target specific controller with CONTROLLER=x.'

task :api => :environment do
  all_routes = ENV['CONTROLLER'] ? ActionController::Routing::Routes.routes.select { |route| route.defaults[:controller] == ENV['CONTROLLER'] } : ActionController::Routing::Routes.routes
  routes = []
  all_routes.each do |route|
    reqs = route.requirements.empty? ? "" : route.requirements[:controller] + '#' + route.requirements[:action]
    if route.path.starts_with?("/api")
        routes << {:name => route.name, 
          :verb => route.verb == nil ? "GET" : route.verb, 
          :path => route.path.sub("(.:format)",""), 
          :controller => route.requirements[:controller]}
    end
  end
  
  routes.sort! do |r1, r2|
    r1[:path] <=> r2[:path]
  end
  
  if ENV['TEXT']
    filename = 'api.txt'
    puts "Generating #{filename}"
    File.open(File.join(RAILS_ROOT, filename), "w") do |f|
      f.puts "Katello API"
      f.puts "-----------"
      f.puts "generated on #{Time.new()}"
      f.puts("")
      f.puts "%-6s %-50s %s" % ["Verb", "Path", "Controller"]
      f.puts "%-6s %-50s %s" % ["====", "====", "=========="]
      routes.each do |r|
        f.puts "%-6s %-50s %s" % [r[:verb], r[:path], r[:controller]]
      end
    end
  elsif ENV['TRAC']
    filename = 'api.trac'
    puts "Generating #{filename}"
    File.open(File.join(RAILS_ROOT, filename), "w") do |f|
      f.puts "== Katello API =="
      f.puts "generated on #{Time.new()}"
      f.puts("")
      f.puts "||'''Verb'''||'''Path'''||'''Controller'''||"
      routes.each do |r|
        f.puts "||#{r[:verb]}||#{r[:path]}||#{r[:controller]}||"
      end
    end
  else
    filename = 'api.html'
    puts "Generating #{filename}"
    File.open(File.join(RAILS_ROOT, filename), "w") do |f|
      f.puts "<html><head><title>Katello API</title></head><body>"
      f.puts "<h2>Katello API</h2>"      
      f.puts "<h4>generated on #{Time.new()}</h4>"
      f.puts "<table border=1><tr><th>Verb</th><th>Path</th><th>Controller</th></tr>"
      routes.each do |r|
        f.puts "<tr><td>#{r[:verb]}</td><td>#{r[:path]}</td><td>#{r[:controller]}</td></tr>"
      end
      f.puts "</table></body></html>"
    end
  end
end
