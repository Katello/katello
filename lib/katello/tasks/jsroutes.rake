desc 'Regenerates js routes'
task :jsroutes => :environment do
  JsRoutes.generate!(Rails.root.join('app', 'assets', 'javascripts', 'common', 'routes.js'), :namespace => 'KT.routes', :exclude =>[ /^admin_/])
  JsRoutes.generate!(Rails.root.join('app', 'assets', 'javascripts', 'common', 'bastion-routes.js'), :namespace => 'BASTION.KT.routes', :exclude =>[ /^admin_/], :camel_case => true)
end
