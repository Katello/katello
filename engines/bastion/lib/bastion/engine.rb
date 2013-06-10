require 'ui_alchemy-rails'

module Bastion
  class Engine < ::Rails::Engine
    isolate_namespace Bastion

    initializer "bastion.assets.paths", :group => :all do |app|
      app.config.assets.paths << Bastion::Engine.root.join('app', 'assets')
      app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets')

      # Slight hack due to how import loading of SCSS looks up paths
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-forms"
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-buttons"

      app.middleware.use ::ActionDispatch::Static, "#{root}/app/assets/bastion"
    end
  end
end
