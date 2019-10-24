module Katello
  HOST_TASKS_QUEUE = :hosts_queue

  class Engine < ::Rails::Engine
    isolate_namespace Katello

    initializer 'katello.selective_params_parser', :before => :build_middleware_stack do |app|
      require 'katello/prevent_json_parsing'
      app.middleware.insert_after(
        Rack::MethodOverride,
        Katello::PreventJsonParsing,
        ->(env) { env['PATH_INFO'] =~ /consumers/ && env['PATH_INFO'] =~ /profile|packages/ }
      )
    end

    initializer 'katello.mount_engine', :before => :sooner_routes_load, :after => :build_middleware_stack do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/mount_engine.rb"
    end

    initializer 'katello.load_default_settings', :before => :load_config_initializers do
      default_settings = {
        :use_pulp => true,
        :use_cp => true,
        :rest_client_timeout => 30,
        :gpg_strict_validation => false,
        :redhat_repository_url => 'https://cdn.redhat.com',
        :consumer_cert_rpm => 'katello-ca-consumer-latest.noarch.rpm',
        :consumer_cert_sh => 'katello-rhsm-consumer',
        :event_daemon_enabled => true,
        :pulp => {
          :default_login => 'admin',
          :url => 'https://localhost/pulp/api/v2/',
          :bulk_load_size => 2000,
          :skip_checksum_validation => false,
          :upload_chunk_size => 1_048_575, # upload size in bytes to pulp. see SSLRenegBufferSize in apache
          :sync_threads => 4,
          :sync_KBlimit => nil,
          :notifier_ca_path => "/etc/pki/tls/certs/ca-bundle.crt"
        },
        :candlepin => {
          :url => 'https://localhost:8443/candlepin',
          :oauth_key => 'katello',
          :oauth_secret => 'katello',
          :ca_cert_file => nil,
          :bulk_load_size => 1000
        }
      }

      SETTINGS[:katello] = default_settings.deep_merge(SETTINGS[:katello] || {})

      require_dependency File.expand_path('../../../app/models/setting/content.rb', __FILE__) if (Setting.table_exists? rescue(false))
    end

    initializer "katello.apipie" do
      Apipie.configuration.checksum_path += ['/katello/api/']
      require 'katello/apipie/validators'
    end

    # make sure the Katello plugin is initialized before `after_initialize`
    # hook so that the resumed Dynflow tasks can rely on everything ready.
    initializer 'katello.register_plugin', :before => :finisher_hook do
      require 'katello/plugin'
      # extend builtin permissions from core with new actions
      require 'katello/permissions'
    end

    initializer "katello.register_actions", :before => :finisher_hook do |_app|
      ForemanTasks.dynflow.require!
      if (Setting.table_exists? rescue(false)) && Setting['host_tasks_workers_pool_size'].to_i > 0
        ForemanTasks.dynflow.config.queues.add(HOST_TASKS_QUEUE, :pool_size => Setting['host_tasks_workers_pool_size'])
      end

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

    initializer "katello.paths", :before => :sooner_routes_load do |app|
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/v2.rb"
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/rhsm.rb"
      app.routes_reloader.paths << "#{Katello::Engine.root}/config/routes/api/registry.rb"
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

    initializer "katello.event_daemon" do |app|
      app.executor.to_run do
        if app.reloader.check!
          Katello::EventDaemon.stop # stop daemon when we are about to reload code
        end
      end

      app.reloader.to_prepare do
        Katello::EventQueue.register_event(Katello::Events::ImportHostApplicability::EVENT_TYPE, Katello::Events::ImportHostApplicability)
        Katello::EventQueue.register_event(Katello::Events::ImportPool::EVENT_TYPE, Katello::Events::ImportPool)
        Katello::EventQueue.register_event(Katello::Events::AutoPublishCompositeView::EVENT_TYPE, Katello::Events::AutoPublishCompositeView)

        Katello::EventDaemon.start
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

      # Lib Extensions
      ::Foreman::Renderer::Scope::Variables::Base.send :include, Katello::Concerns::RendererExtensions
      ::Foreman::Renderer::Scope::Base.send :include, Katello::Concerns::BaseTemplateScopeExtensions

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
      ::HttpProxy.send :include, Katello::Concerns::HttpProxyExtensions
      ForemanTasks::RecurringLogic.send :include, Katello::Concerns::RecurringLogicExtensions

      #Controller extensions
      ::HostsController.send :include, Katello::Concerns::HostsControllerExtensions
      ::SmartProxiesController.send :include, Katello::Concerns::SmartProxiesControllerExtensions
      ::SmartProxiesController.send :include, Katello::Concerns::SmartProxiesControllerExtensions
      ::FactImporter.register_fact_importer(Katello::RhsmFactName::FACT_TYPE, Katello::RhsmFactImporter)
      ::FactParser.register_fact_parser(Katello::RhsmFactName::FACT_TYPE, Katello::RhsmFactParser)

      #Helper Extensions
      ::SmartProxiesController.class_eval do
        helper Katello::Concerns::SmartProxyHelperExtensions
      end

      ::DashboardController.class_eval do
        helper Katello::Concerns::DashboardHelperExtensions
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

      #Api controller extensions
      ::Api::V2::HostsController.send :include, Katello::Concerns::Api::V2::HostsControllerExtensions
      ::Api::V2::HostgroupsController.send :include, Katello::Concerns::Api::V2::HostgroupsControllerExtensions
      ::Api::V2::SmartProxiesController.send :include, Katello::Concerns::Api::V2::SmartProxiesControllerExtensions

      ::HostsController.class_eval do
        helper Katello::Concerns::HostsAndHostgroupsHelperExtensions
      end

      ::HostgroupsController.class_eval do
        helper Katello::Concerns::HostsAndHostgroupsHelperExtensions
      end

      ::AuditSearch::ClassMethods.prepend Katello::Concerns::AuditSearch

      load 'katello/repository_types.rb'
      load 'katello/scheduled_jobs.rb'
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

  def self.with_ansible?
    (ForemanAnsible rescue false) ? true : false
  end
end
