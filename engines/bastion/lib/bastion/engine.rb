require 'rails'

module Bastion
  class Engine < ::Rails::Engine
    isolate_namespace Bastion

    initializer 'bastion.assets_dispatcher', :before => :build_middleware_stack do |app|
      app.middleware.use ::ActionDispatch::Static, "#{Bastion::Engine.root}/app/assets/javascripts/bastion"
    end

    initializer 'bastion.mount_engine', :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << "#{Bastion::Engine.root}/config/routes/mount_engine.rb"
      app.routes_reloader.paths.unshift("#{Bastion::Engine.root}/config/routes.rb")
    end

    initializer "bastion.assets", :group => :all do |app|
      app.config.assets.paths << "#{Bastion::Engine.root}/vendor/assets/stylesheets/bastion"
    end

    initializer "bastion.configure_assets", :group => :all do |_app|
      SETTINGS[:bastion] = {:assets => {}} if SETTINGS[:bastion].nil?
      SETTINGS[:bastion][:assets] = {} if SETTINGS[:bastion][:assets].nil?

      SETTINGS[:bastion][:assets][:precompile] = [
        'bastion/bastion.css',
        'bastion/bastion.js'
      ]

      locale_files = Dir.glob("#{Bastion::Engine.root}/vendor/assets/javascripts/#{Bastion.localization_path("*")}")
      locale_files.map do |file|
        file.gsub!("#{Bastion::Engine.root}/vendor/assets/javascripts/", "")
      end

      SETTINGS[:bastion][:assets][:precompile].concat(locale_files)
    end

    initializer 'bastion.assets.precompile', :after => 'bastion.configure_assets' do |app|
      app.config.assets.precompile += SETTINGS[:bastion][:assets][:precompile]
    end

    initializer "angular_templates", :group => :all do |app|
      app.config.angular_templates.ignore_prefix = %w([bastion]*\/+)
    end
  end
end
