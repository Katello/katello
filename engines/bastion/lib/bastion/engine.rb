module Bastion
  class Engine < ::Rails::Engine

    isolate_namespace Bastion

    initializer 'bastion.assets_dispatcher', :before => :build_middleware_stack do |app|
      app.middleware.use ::ActionDispatch::Static, "#{Bastion::Engine.root}/app/assets/javascripts/bastion"
    end

    initializer "bastion.assets.paths", :group => :all do |app|
      app.config.less.paths << "#{Bastion::Engine.root}/app/assets/stylesheets/bastion"
      app.config.less.paths << "#{Bastion::Engine.root}/vendor/assets/stylesheets/bastion"
      app.middleware.use ::ActionDispatch::Static, "#{Bastion::Engine.root}/app/assets/javascripts/bastion"
    end
  end
end
