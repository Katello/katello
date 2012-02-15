task :jsroutes => :environment do
  JsRoutes.generate!(:namespace => 'KT.routes', :exclude =>[ /^admin_/,/^api/ ])
end
