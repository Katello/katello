task :jsroutes do
  JsRoutes.generate!(:namespace => 'KT.routes', :exclude => /^admin_/)
end