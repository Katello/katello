desc 'Generate list of actions and permissions. Target specific controller with CONTROLLER=x.'

module Kernel
  def qualified_const_get(str)
    path = str.to_s.split('::')
    from_root = path[0].empty?
    if from_root
      from_root = []
      path = path[1..-1]
    else
      start_ns = ((Class === self)||(Module === self)) ? self : self.class
      from_root = start_ns.to_s.split('::')
    end
    until from_root.empty?
      begin
        return (from_root+path).inject(Object) { |ns,name| ns.const_get(name) }
      rescue NameError
        from_root.delete_at(-1)
      end
    end
    path.inject(Object) { |ns,name| ns.const_get(name) }
  end
end

task :list_permissions => :environment do
  URL='http://git.fedorahosted.org/git/?p=katello.git;a=blob;f=src/'
  puts "||Controller||Action||Permission implementation||"
  all_routes = ENV['CONTROLLER'] ?
    ActionController::Routing::Routes.routes.select {
      |route| route.defaults[:controller] == ENV['CONTROLLER']
    } : ActionController::Routing::Routes.routes
  routes = all_routes.collect do |route|
    action = route.requirements[:action]
    klass_name = "#{route.requirements[:controller].camelize}Controller"
    begin
      klass = Kernel.qualified_const_get klass_name
      inst = klass.new
      rules = inst.rules || {}
      rule = rules[action.to_sym] || ""
      # source_location works only for 1.9+
      rule = rule.to_s.match(/#{RAILS_ROOT}\/.*:\d+/).to_s.sub(/#{RAILS_ROOT}\//, '') || "yes"
    rescue Exception => e
      rule = ""
      #rule = e.message
    end
    if rule == ""
      url = "wiki:"
    else
      url = URL + rule.sub(":", '#l')
    end
    puts "||[#{url} #{klass_name}]||#{action}||#{rule}||"
  end
  puts "\nGenerated with ''rake list_permissions'' on #{Time.now} GMT+1"
end
