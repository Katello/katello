module Katello

  class Engine < ::Rails::Engine

    isolate_namespace Katello

    initializer 'katello.mount_engine', :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/mount_engine.rb"
    end

    initializer "katello.simple_navigation" do |app|
      SimpleNavigation.config_file_paths << File.expand_path("../../../config", __FILE__)
    end

    initializer "katello.apipie" do
      # When Katello is loaded, the apidoc is restricted just to the Katello controllers.
      # This way, it's possible to generate both Foreman bindings (when Katello is not loaded)
      # or just Katello bindings (when Katello loaded) the same way.
      Apipie.configuration.api_controllers_matcher = "#{Katello::Engine.root}/app/controllers/katello/api/v2/*.rb"
    end

    initializer "katello.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += Katello::Engine.paths['db/migrate'].existent
      app.config.autoload_paths += Dir["#{config.root}/app/lib"]
      app.config.autoload_paths += Dir["#{config.root}/app/services/katello"]
      app.config.autoload_paths += Dir["#{config.root}/app/views/foreman"]
    end

    initializer "katello.assets.paths", :group => :all do |app|
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-forms"
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-buttons"
      app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
                                                           'font-awesome', 'scss')
    end

    initializer "katello.paths" do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v1.rb"
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v2.rb"
    end

    initializer "katello.helpers" do |app|
      ActionView::Base.send :include, Katello::TaxonomyHelper
      ActionView::Base.send :include, Katello::HostsAndHostgroupsHelper
      ActionView::Base.send :include, Katello::KatelloUrlsHelper
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

    initializer :register_assets do |app|
      if Rails.env.production?
        assets = YAML.load_file("#{Katello::Engine.root}/public/assets/katello/manifest.yml")

        assets.each_pair do |file, digest|
          app.config.assets.digests[file] = digest
        end
      end
    end

    config.to_prepare do
      FastGettext.add_text_domain('katello', {
        :path => File.expand_path("../../../locale", __FILE__),
        :type => :po,
        :ignore_fuzzy => true,
        :report_warning => false
        })
      FastGettext.default_text_domain = 'katello'

      # Model extensions
      ::Environment.send :include, Katello::Concerns::EnvironmentExtensions
      ::Medium.send :include, Katello::Concerns::MediumExtensions
      ::Operatingsystem.send :include, Katello::Concerns::OperatingsystemExtensions
      ::Organization.send :include, Katello::Concerns::OrganizationExtensions
      ::User.send :include, Katello::Concerns::UserExtensions

      # Service extensions
      require "#{Katello::Engine.root}/app/services/katello/puppet_class_importer_extensions"
      ::PuppetClassImporter.send :include, Katello::Services::PuppetClassImporterExtensions
    end

    initializer 'katello.register_plugin', :after => :disable_dependency_loading do
      require 'katello/plugin'
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        Katello::Engine.load_seed
      end
      load "#{Katello::Engine.root}/lib/katello/tasks/test.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/jenkins.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/setup.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/cdn_refresh.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/delete_orphaned_content.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/regenerate_repo_metadata.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/reindex.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/rubocop.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/asset_compile.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/clean_backend_objects.rake"
    end

  end

end
