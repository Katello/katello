module Katello

  class Engine < ::Rails::Engine

    isolate_namespace Katello
    engine_name 'katello'

    initializer "katello.simple_navigation" do |app|
      SimpleNavigation::config_file_paths << File.expand_path("../../../config", __FILE__)
    end

    initializer "katello.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += Katello::Engine.paths['db/migrate'].existent
      app.config.autoload_paths += Dir["#{config.root}/app/lib)"]
    end

    initializer "katello.assets.paths", :group => :all do |app|
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-forms"
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-buttons"
      app.config.assets.paths << "#{::Katello::Engine.root}/vendor/assets/stylesheets/katello/font-awesome"
      end

    initializer "katello.paths" do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v1.rb"
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v2.rb"
    end

    initializer "logging" do |app|
      if caller.last =~ /script\/delayed_job:\d+$/ ||
          ((caller[-10..-1] || []).any? {|l| l =~ /\/rake/} && ARGV.include?("jobs:work"))
        Katello::Logging.configure(:prefix => 'delayed_')
        Delayed::Worker.logger = ::Logging.logger['app']
      else
        Katello::Logging.configure
      end

      app.config.logger = ::Logging.logger['app']
      app.config.active_record.logger = ::Logging.logger['sql']
    end

    config.to_prepare do
      # Model extensions
      ::User.send :include, Katello::Concerns::UserExtensions
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        Katello::Engine.load_seed
      end
    end

  end

end
