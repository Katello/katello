module Katello

  class Engine < ::Rails::Engine

    initializer 'katello.mount_engine', :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/mount_engine.rb"
    end

    isolate_namespace Katello

    initializer "katello.simple_navigation" do |app|
      SimpleNavigation.config_file_paths << File.expand_path("../../../config", __FILE__)
    end

    initializer "katello.apipie" do
      # When Katello is loaded, the apidoc is restricted just to the Katello controllers.
      # This way, it's possible to generate both Foreman bindings (when Katello is not loaded)
      # or just Katello bindings (when Katello loaded) the same way.
      Apipie.configuration.api_controllers_matcher = "#{Katello::Engine.root}/app/controllers/katello/api/v2/*.rb"
    end

    initializer "katello.register_actions" do |app|
      require 'actions'
      Actions.eager_load_paths.concat(%W[#{Katello::Engine.root}/app/lib/actions
                                         #{Katello::Engine.root}/app/lib/headpin/actions
                                         #{Katello::Engine.root}/app/lib/katello/actions ])
      Actions.eager_load!
    end

    initializer "katello.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += Katello::Engine.paths['db/migrate'].existent
      app.config.autoload_paths += Dir["#{config.root}/app/lib)"]
    end

    initializer "katello.assets.paths", :group => :all do |app|
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-forms"
      app.config.assets.paths << "#{::UIAlchemy::Engine.root}/vendor/assets/ui_alchemy/alchemy-buttons"
      app.config.sass.load_paths << "#{Bastion::Engine.root}/vendor/assets/components/font-awesome/scss"
    end

    initializer "katello.paths" do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v1.rb"
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v2.rb"
    end

    initializer "katello.helpers" do |app|
      ActionView::Base.send :include, Katello::TaxonomyHelper
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
      FastGettext.add_text_domain('katello', {
        :path => File.expand_path("../../../locale", __FILE__),
        :type => :po,
        :ignore_fuzzy => true,
        :report_warning => false
        })
      FastGettext.default_text_domain = 'katello'

      # Model extensions
      ::User.send :include, Katello::Concerns::UserExtensions
      ::Organization.send :include, Katello::Concerns::OrganizationExtensions
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
    end

  end

end
