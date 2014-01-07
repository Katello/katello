require 'ui_alchemy-rails'

module Bastion
  class Engine < ::Rails::Engine
    isolate_namespace Bastion

    initializer "bastion.assets.paths", :group => :all do |app|
      app.config.assets.paths << Bastion::Engine.root.join('app', 'assets')
      app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
                                                           'font-awesome', 'scss')
      app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets', 'fonts')

      app.config.less.paths << "#{Bastion::Engine.root}/vendor/assets/stylesheets/bastion"

      app.middleware.use ::ActionDispatch::Static, "#{Bastion::Engine.root}/app/assets/bastion"

      app.config.assets.precompile << proc do |path|
        full_path = Rails.application.assets.resolve(path).to_path
        if path =~ /\.(css|js)\z/
          if full_path.include?("bastion.js")
            puts "Including Bastion master JS file"
            true
          elsif full_path.include?("bastion.scss")
            puts "Including Bastion master SCSS file"
            true
          elsif full_path.include?("bastion.less")
            puts "Including Bastion master LESS file"
            true
          else
            false
          end
        else
          false
        end
      end

    end
  end
end
