desc 'Regenerates js routes'
task :jsroutes => :environment do
  JsRoutes.generate!(:namespace => 'KT.routes', :exclude =>[ /^admin_/ ])
end
