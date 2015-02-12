module Katello
  class Engine < ::Rails::Engine
    isolate_namespace Katello

    initializer 'katello.silenced_logger', :before => :build_middleware_stack do |app|
      app.config.middleware.swap Rails::Rack::Logger, Katello::Middleware::SilencedLogger, {}
    end

    initializer 'katello.mount_engine', :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/mount_engine.rb"
    end

    initializer 'katello.load_default_settings', :before => :load_config_initializers do
      require_dependency File.expand_path('../../../app/models/setting/katello.rb', __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer "katello.apipie" do
      Apipie.configuration.api_controllers_matcher << "#{Katello::Engine.root}/app/controllers/katello/api/v2/*.rb"
      Apipie.configuration.ignored += %w(Api::V2::OrganizationsController)
      Apipie.configuration.checksum_path += ['/katello/api/']
      require 'katello/apipie/validators'
    end

    initializer "katello.register_actions", :before => 'foreman_tasks.initialize_dynflow' do |_app|
      ForemanTasks.dynflow.require!
      action_paths = %W(#{Katello::Engine.root}/app/lib/actions
                        #{Katello::Engine.root}/app/lib/headpin/actions
                        #{Katello::Engine.root}/app/lib/katello/actions)
      ForemanTasks.dynflow.config.eager_load_paths.concat(action_paths)
    end

    initializer "katello.set_dynflow_middlewares", :before => 'foreman_tasks.initialize_dynflow' do |_app|
      # We don't enable this in test env, as it adds the new field into the actions input
      # that we are not interested in tests
      unless Rails.env.test?
        ForemanTasks.dynflow.config.on_init do |world|
          world.middleware.use ::Actions::Middleware::KeepLocale
        end
      end
    end

    initializer "katello.initialize_cp_listener", after: "foreman_tasks.initialize_dynflow" do
      unless ForemanTasks.dynflow.config.remote? || File.basename($PROGRAM_NAME) == 'rake' || Rails.env.test?
        ForemanTasks.async_task(::Actions::Candlepin::ListenOnCandlepinEvents)
      end
    end

    initializer "katello.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += Katello::Engine.paths['db/migrate'].existent
      app.config.autoload_paths += Dir["#{config.root}/app/lib"]
      app.config.autoload_paths += Dir["#{config.root}/app/presenters"]
      app.config.autoload_paths += Dir["#{config.root}/app/services/katello"]
      app.config.autoload_paths += Dir["#{config.root}/app/views/foreman"]
    end

    initializer "katello.assets.paths", :group => :all do |app|
      if Rails.env.production?
        app.config.assets.paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
                                                             'font-awesome', 'scss')
      else
        app.config.sass.load_paths << Bastion::Engine.root.join('vendor', 'assets', 'stylesheets', 'bastion',
                                                                'font-awesome', 'scss')
      end
    end

    initializer "katello.paths" do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v2.rb"
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/rhsm.rb"
      app.routes_reloader.paths.unshift("#{Katello::Engine.root}/config/routes/overrides.rb")
    end

    initializer "katello.helpers" do |_app|
      ActionView::Base.send :include, Katello::TaxonomyHelper
      ActionView::Base.send :include, Katello::HostsAndHostgroupsHelper
      ActionView::Base.send :include, Katello::KatelloUrlsHelper
    end

    initializer "logging" do |app|
      Katello::Logging.configure

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
      FastGettext.add_text_domain('katello',
                                    :path => File.expand_path("../../../locale", __FILE__),
                                    :type => :po,
                                    :ignore_fuzzy => true,
                                    :report_warning => false
                                  )
      FastGettext.default_text_domain = 'katello'

      unless SETTINGS[:organizations_enabled]
        fail Foreman::Exception, N_("Organizations disabled, try allowing them in foreman/config/settings.yaml")
      end

      # Model extensions
      ::Environment.send :include, Katello::Concerns::EnvironmentExtensions
      ::Host::Managed.send :include, Katello::Concerns::HostManagedExtensions
      ::Hostgroup.send :include, Katello::Concerns::HostgroupExtensions
      ::Location.send :include, Katello::Concerns::LocationExtensions
      ::Medium.send :include, Katello::Concerns::MediumExtensions
      ::Redhat.send :include, Katello::Concerns::RedhatExtensions
      ::Organization.send :include, Katello::Concerns::OrganizationExtensions
      ::User.send :include, Katello::Concerns::UserExtensions

      ::Container.send :include, Katello::Concerns::ContainerExtensions
      ::DockerContainerWizardState.send :include, Katello::Concerns::DockerContainerWizardStateExtensions

      #Controller extensions
      ::OperatingsystemsController.send :include, Katello::Concerns::OperatingsystemsControllerExtensions
      ::HostsController.send :include, Katello::Concerns::HostsControllerExtensions
      ::Containers::StepsController.send :include, Katello::Concerns::Containers::StepsControllerExtensions

      #Helper Extensions
      ::Containers::StepsController.class_eval do
        helper Katello::Concerns::ForemanDocker::ContainerStepsHelperExtensions
      end

      #Handle Smart Proxy items separately
      begin
        ::SmartProxy.send :include, Katello::Concerns::SmartProxyExtensions
        ::SmartProxiesController.send :include, Katello::Concerns::SmartProxiesControllerExtensions
        rescue ActiveRecord::StatementInvalid
          Rails.logger.info('Database was not initialized yet: skipping smart proxy katello extension')
      end

      # Organization controller extensions
      ::OrganizationsController.send :include, Katello::Concerns::OrganizationsControllerExtensions

      # Service extensions
      require "#{Katello::Engine.root}/app/services/katello/puppet_class_importer_extensions"

      # We need to explicitly load this files because Foreman has
      # similar strucuture and if the Foreman files are loaded first,
      # autoloading doesn't work.
      require_dependency "#{Katello::Engine.root}/app/controllers/katello/api/api_controller"
      require_dependency "#{Katello::Engine.root}/app/controllers/katello/api/v2/api_controller"
      ::PuppetClassImporter.send :include, Katello::Services::PuppetClassImporterExtensions

      #Api controller extensions
      ::Api::V2::HostsController.send :include, Katello::Concerns::Api::V2::HostsControllerExtensions
      ::Api::V2::HostgroupsController.send :include, Katello::Concerns::Api::V2::HostgroupsControllerExtensions
    end

    initializer 'katello.register_plugin', :after => :finisher_hook do
      require 'katello/plugin'
      require 'katello/permissions'
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        Katello::Engine.load_seed
      end
      load "#{Katello::Engine.root}/lib/katello/tasks/test.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/jenkins.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/setup.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/delete_orphaned_content.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/regenerate_repo_metadata.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/reindex.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/rubocop.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/asset_compile.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/clean_backend_objects.rake"

      load "#{Katello::Engine.root}/lib/katello/tasks/upgrades/2.1/import_errata.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/upgrades/2.2/update_gpg_key_urls.rake"
    end
  end
end
