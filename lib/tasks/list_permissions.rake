#
# Example:
#   CONTROLLER="api/systems" TEXT=1 rake list_permissions
#

desc 'Generate list of actions and permissions. Target specific controller with CONTROLLER=x.'

task :list_permissions => :environment do
  URL='http://git.fedorahosted.org/git/?p=katello.git;a=blob;f=src/'
  puts "||Controller||Action||Permission implementation||Notes||"
  all_routes = ENV['CONTROLLER'] ?
    ActionController::Routing::Routes.routes.select {
      |route| route.defaults[:controller] == ENV['CONTROLLER']
    } : ActionController::Routing::Routes.routes
  all_routes.each do |route|
    action = route.requirements[:action]
    klass_name = route.requirements[:controller].camelize + 'Controller'
    begin
      klass = eval(klass_name)
      inst = klass.new
      rules = inst.rules || {}
      full_rule = rules[action.to_sym] || ""
      # source_location works only for 1.9+
      rule = full_rule.to_s.match(/#{Rails.root}\/.*:\d+/).to_s.sub(/#{Rails.root}\//, '')
      notes = ""
    rescue Exception => e
      rule = ""
      notes = e.message
    end
    if rule == ""
      url = "wiki:"
    else
      url = URL + rule.sub(":", '#l')
    end
    if ENV['TEXT'].nil?
      puts "||[#{url} #{klass_name}]|| #{action} || #{rule} || #{notes} ||"
    else
      puts "#{klass_name} #{action} #{full_rule} #{notes}"
    end
  end
  puts "\nGenerated with ''rake list_permissions'' on #{Time.now} GMT+1"
end
