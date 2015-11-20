module Katello
  class Engine < ::Rails::Engine
    isolate_namespace Katello

    initializer 'katello.mount_engine', :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/mount_engine.rb"
    end

    initializer 'katello.load_default_settings', :before => :load_config_initializers do
      default_settings = {
        :use_pulp => true,
        :use_cp => true,
        :rest_client_timeout => 30,
        :gpg_strict_validation => false,
        :puppet_repo_root => '/etc/puppet/environments/',
        :redhat_repository_url => 'https://cdn.redhat.com',
        :post_sync_url => 'http://localhost:3000/katello/api/v2/repositories/sync_complete?token=katello',
        :consumer_cert_rpm => 'katello-ca-consumer-latest.noarch.rpm',
        :pulp => {
          :default_login => 'admin',
          :url => 'https://localhost/pulp/api/v2/',
          :oauth_key => 'katello',
          :oauth_secret => 'katello',
          :bulk_load_size => 100,
          :skip_checksum_validation => false,
          :upload_chunk_size => 1_048_575, # upload size in bytes to pulp. see SSLRenegBufferSize in apache
          :sync_threads => 4,
          :sync_KBlimit => nil
        },
        :candlepin => {
          :url => 'https://localhost:8443/candlepin',
          :oauth_key => 'katello',
          :oauth_secret => 'katello',
          :ca_cert_file => nil
        }
      }

      SETTINGS[:katello] = default_settings.deep_merge(SETTINGS[:katello] || {})

      require_dependency File.expand_path('../../../app/models/setting/katello.rb', __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer "katello.apipie" do
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
        ForemanTasks.dynflow.config.on_init do |world|
          ::Actions::Candlepin::ListenOnCandlepinEvents.ensure_running(world)
        end
      end
    end

    initializer "katello.load_app_instance_data" do |app|
      Katello::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end

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

      # Lib Extensions
      ::Foreman::Renderer.send :include, Katello::Concerns::RendererExtensions

      # Model extensions
      ::Environment.send :include, Katello::Concerns::EnvironmentExtensions
      ::Host::Managed.send :include, Katello::Concerns::HostManagedExtensions
      ::Host::Managed.send :include, ::Katello::Concerns::ContentAspectHostExtensions
      ::Host::Managed.send :include, ::Katello::Concerns::SubscriptionAspectHostExtensions
      ::Hostgroup.send :include, Katello::Concerns::HostgroupExtensions
      ::Location.send :include, Katello::Concerns::LocationExtensions
      ::Medium.send :include, Katello::Concerns::MediumExtensions
      ::Redhat.send :include, Katello::Concerns::RedhatExtensions
      ::Operatingsystem.send :include, Katello::Concerns::OperatingsystemExtensions
      ::Organization.send :include, Katello::Concerns::OrganizationExtensions
      ::User.send :include, Katello::Concerns::UserExtensions

      ::Container.send :include, Katello::Concerns::ContainerExtensions
      ::DockerContainerWizardState.send :include, Katello::Concerns::DockerContainerWizardStateExtensions

      #Controller extensions
      ::OperatingsystemsController.send :include, Katello::Concerns::OperatingsystemsControllerExtensions
      ::HostsController.send :include, Katello::Concerns::HostsControllerExtensions
      ::Containers::StepsController.send :include, Katello::Concerns::Containers::StepsControllerExtensions

      ::FactImporter.register_fact_importer(Katello::RhsmFactName::FACT_TYPE, Katello::RhsmFactImporter)
      ::FactParser.register_fact_parser(Katello::RhsmFactName::FACT_TYPE, Katello::RhsmFactParser)

      #Helper Extensions
      ::Containers::StepsController.class_eval do
        helper Katello::Concerns::ForemanDocker::ContainerStepsHelperExtensions
      end

      #Handle Smart Proxy items separately
      begin
        ::SmartProxy.send :include, Katello::Concerns::SmartProxyExtensions
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
      load "#{Katello::Engine.root}/lib/katello/tasks/upgrades/2.2/update_metadata_expire.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/upgrades/2.4/import_package_groups.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/upgrades/2.4/import_rpms.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/upgrades/2.4/import_distributions.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/upgrades/2.4/import_puppet_modules.rake"
      load "#{Katello::Engine.root}/lib/katello/tasks/upgrades/2.4/import_subscriptions.rake"
    end
  end
end
