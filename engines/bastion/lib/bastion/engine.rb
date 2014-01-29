module Bastion
  class Engine < ::Rails::Engine
    isolate_namespace Bastion

    initializer 'bastion.assets_dispatcher', :before => :build_middleware_stack do |app|
      app.middleware.use ::ActionDispatch::Static, "#{Bastion::Engine.root}/app/assets/javascripts/bastion"
    end

    initializer "bastion.assets.paths", :group => :all do |app|
      app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
                                                           'font-awesome', 'scss')
      app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets', 'fonts')

      app.config.less.paths << "#{Bastion::Engine.root}/app/assets/stylesheets/bastion/less"
      app.config.less.paths << "#{Bastion::Engine.root}/vendor/assets/stylesheets/bastion"
    end
  end
end
