desc 'Regenerates js routes'
task :jsroutes => :environment do
  JsRoutes.generate!(Rails.root.join('app', 'assets', 'javascripts', 'common'), :namespace => 'KT.routes', :exclude =>[ /^admin_/])
end
