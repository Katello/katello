module Bastion
  class Engine < ::Rails::Engine

    isolate_namespace Bastion

    initializer "bastion.assets.paths", :group => :all do |app|
      app.config.less.paths << "#{Bastion::Engine.root}/app/assets/stylesheets/bastion"
      app.config.less.paths << "#{Bastion::Engine.root}/vendor/assets/stylesheets/bastion"
      app.middleware.use ::ActionDispatch::Static, "#{Bastion::Engine.root}/app/assets/javascripts/bastion"
    end

    initializer "angular_templates", :group => :all do |app|
      app.config.angular_templates.ignore_prefix = '[bastion]*\/+'
    end
  end
end
