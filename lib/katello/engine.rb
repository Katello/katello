require 'katello_home_helper_patch'
require 'logging'

module Katello

  class Engine < ::Rails::Engine
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
      # Patch the menu
      ::HomeHelper.send :include, KatelloHomeHelperPatch
    end

  end

  def table_name_prefix
    'katello_'
  end

  def use_relative_model_naming
    true
  end

  def self.table_name_prefix
    'katello_'
  end

end
