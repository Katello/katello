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
        :redhat_repository_url => 'https://cdn.redhat.com',
        :post_sync_url => 'http://localhost:3000/katello/api/v2/repositories/sync_complete?token=katello',
        :consumer_cert_rpm => 'katello-ca-consumer-latest.noarch.rpm',
        :consumer_cert_sh => 'katello-rhsm-consumer',
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

      require_dependency File.expand_path('../../../app/models/setting/content.rb', __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer 'katello.configure_assets', :group => :all do
      def find_assets(args = {})
        type = args.fetch(:type, nil)
        vendor = args.fetch(:vendor, false)

        if vendor
          asset_dir = "#{Katello::Engine.root}/vendor/assets/#{type}/"
        else
          asset_dir = "#{Katello::Engine.root}/app/assets/#{type}/"
        end

        asset_paths = Dir[File.join(asset_dir, '**', '*')].reject { |file| File.directory?(file) }
        asset_paths.each { |file| file.slice!(asset_dir) }

        asset_paths
      end

      javascripts = find_assets(:type => 'javascripts')
      images = find_assets(:type => 'images')
      vendor_images = find_assets(:type => 'images', :vendor => true)

      precompile = [
        'katello/katello.css',
        'katello/containers/container.css',
        'bastion_katello/bastion_katello.css',
        'bastion_katello/bastion_katello.js',
        /bastion_katello\S+.(?:svg|eot|woff|ttf)$/
      ]

      precompile.concat(javascripts)
      precompile.concat(images)
      precompile.concat(vendor_images)

      SETTINGS[:katello] = {} unless SETTINGS.key?(:katello)
      SETTINGS[:katello][:assets] = {:precompile => precompile}
    end

    initializer 'katello.assets.precompile', :after => 'katello.configure_assets' do |app|
      app.config.assets.precompile += SETTINGS[:katello][:assets][:precompile]
    end

    initializer "katello.apipie" do
      Apipie.configuration.checksum_path += ['/katello/api/']
      require 'katello/apipie/validators'
    end

    # make sure the Katello plugin is initialized before `after_initialize`
    # hook so that the resumed Dynflow tasks can rely on everything ready.
    initializer 'katello.register_plugin', :before => :finisher_hook do
      require 'katello/plugin'
      require 'katello/permissions'
    end

    initializer "katello.register_actions", :before => :finisher_hook do |_app|
      ForemanTasks.dynflow.require!
      action_paths = %W(#{Katello::Engine.root}/app/lib/actions
                        #{Katello::Engine.root}/app/lib/headpin/actions
                        #{Katello::Engine.root}/app/lib/katello/actions)
      ForemanTasks.dynflow.config.eager_load_paths.concat(action_paths)
    end

    initializer "katello.set_dynflow_middlewares", :before => :finisher_hook do |_app|
      # We don't enable this in test env, as it adds the new field into the actions input
      # that we are not interested in tests
      unless Rails.env.test?
        ForemanTasks.dynflow.config.on_init do |world|
          world.middleware.use ::Actions::Middleware::KeepLocale
        end
      end
    end

    initializer "katello.initialize_cp_listener", :before => :finisher_hook do
      unless ForemanTasks.dynflow.config.remote? || File.basename($PROGRAM_NAME) == 'rake' || Rails.env.test?
        ForemanTasks.dynflow.config.on_init do |world|
          ::Actions::Candlepin::ListenOnCandlepinEvents.ensure_running(world)
          ::Actions::Katello::EventQueue::Monitor.ensure_running(world)
        end
      end
    end

    initializer "katello.load_app_instance_data" do |app|
      app.config.filter_parameters += [:_json] #package profile parameter
      Katello::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end

      app.config.autoload_paths += Dir["#{config.root}/app/lib"]
      app.config.autoload_paths += Dir["#{config.root}/app/presenters"]
      app.config.autoload_paths += Dir["#{config.root}/app/services/katello"]
      app.config.autoload_paths += Dir["#{config.root}/app/views/foreman"]
    end

    initializer "katello.paths" do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v2.rb"
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/rhsm.rb"
      app.routes_reloader.paths.unshift("#{Katello::Engine.root}/config/routes/overrides.rb")
    end

    initializer "katello.add_rabl_view_path" do
      Rabl.configure do |config|
        config.view_paths << Katello::Engine.root.join('app', 'views')
      end
    end

    initializer "katello.helpers" do |_app|
      ActionView::Base.send :include, Katello::TaxonomyHelper
      ActionView::Base.send :include, Katello::HostsAndHostgroupsHelper
      ActionView::Base.send :include, Katello::KatelloUrlsHelper
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

      # Rendering concerns needs to be injected to controllers, Foreman::Renderer was already included
      # otherwise subscription_manager_configuration_url is not available in template preview
      (TemplatesController.descendants + [TemplatesController]).each do |klass|
        klass.send(:include, Katello::KatelloUrlsHelper)
      end
      # Lib Extensions
      ::Foreman::Renderer.send :include, Katello::Concerns::RendererExtensions

      # Model extensions
      ::Environment.send :include, Katello::Concerns::EnvironmentExtensions
      ::Host::Managed.send :include, Katello::Concerns::HostManagedExtensions
      ::Hostgroup.send :include, Katello::Concerns::HostgroupExtensions
      ::Location.send :include, Katello::Concerns::LocationExtensions
      ::Redhat.send :include, Katello::Concerns::RedhatExtensions
      ::Operatingsystem.send :include, Katello::Concerns::OperatingsystemExtensions
      ::Organization.send :include, Katello::Concerns::OrganizationExtensions
      ::User.send :include, Katello::Concerns::UserExtensions
      ::Setting.send :include, Katello::Concerns::SettingExtensions
      ::Container.send :include, Katello::Concerns::ContainerExtensions
      ::DockerContainerWizardState.send :include, Katello::Concerns::DockerContainerWizardStateExtensions

      #Controller extensions
      ::HostsController.send :include, Katello::Concerns::HostsControllerExtensions
      ::SmartProxiesController.send :include, Katello::Concerns::SmartProxiesControllerExtensions
      ::Containers::StepsController.send :include, Katello::Concerns::Containers::StepsControllerExtensions
      ::SmartProxiesController.send :include, Katello::Concerns::SmartProxiesControllerExtensions

      ::FactImporter.register_fact_importer(Katello::RhsmFactName::FACT_TYPE, Katello::RhsmFactImporter)
      ::FactParser.register_fact_parser(Katello::RhsmFactName::FACT_TYPE, Katello::RhsmFactParser)

      #Helper Extensions
      ::Containers::StepsController.class_eval do
        helper Katello::Concerns::ForemanDocker::ContainerStepsHelperExtensions
      end

      ::SmartProxiesController.class_eval do
        helper Katello::Concerns::SmartProxyHelperExtensions
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
      require "#{Katello::Engine.root}/lib/proxy_api/pulp"
      require "#{Katello::Engine.root}/lib/proxy_api/pulp_node"

      # We need to explicitly load this files because Foreman has
      # similar strucuture and if the Foreman files are loaded first,
      # autoloading doesn't work.
      require_dependency "#{Katello::Engine.root}/app/lib/katello/api/v2/rendering"
      require_dependency "#{Katello::Engine.root}/app/controllers/katello/api/api_controller"
      require_dependency "#{Katello::Engine.root}/app/controllers/katello/api/v2/api_controller"
      require_dependency "#{Katello::Engine.root}/app/services/katello/proxy_status/pulp"
      require_dependency "#{Katello::Engine.root}/app/services/katello/proxy_status/pulp_node"
      ::PuppetClassImporter.send :include, Katello::Services::PuppetClassImporterExtensions

      #facet extensions
      ::Host::Managed.send :include, ::Katello::Concerns::ContentFacetHostExtensions
      ::Host::Managed.send :include, ::Katello::Concerns::SubscriptionFacetHostExtensions

      #Api controller extensions
      ::Api::V2::HostsController.send :include, Katello::Concerns::Api::V2::HostsControllerExtensions
      ::Api::V2::HostgroupsController.send :include, Katello::Concerns::Api::V2::HostgroupsControllerExtensions
      ::Api::V2::SmartProxiesController.send :include, Katello::Concerns::Api::V2::SmartProxiesControllerExtensions

      ::SettingsController.class_eval do
        helper Katello::Concerns::SettingsHelperExtensions
      end

      Katello::EventQueue.register_event(Katello::Events::ImportHostApplicability::EVENT_TYPE, Katello::Events::ImportHostApplicability)
      Katello::EventQueue.register_event(Katello::Events::ImportPool::EVENT_TYPE, Katello::Events::ImportPool)

      ::HostsController.class_eval do
        helper Katello::Concerns::HostsAndHostgroupsHelperExtensions
      end

      ::HostgroupsController.class_eval do
        helper Katello::Concerns::HostsAndHostgroupsHelperExtensions
      end

      load 'katello/repository_types.rb'
    end

    rake_tasks do
      Dir["#{Katello::Engine.root}/lib/katello/tasks/**/*"].each do |task|
        load task if File.file?(task)
      end
    end
  end

  # check whether foreman_remote_execution to integrate is available in the system
  def self.with_remote_execution?
    (RemoteExecutionFeature rescue false) ? true : false
  end
end
