module BastionKatello
  class Engine < ::Rails::Engine
    isolate_namespace BastionKatello

    initializer 'bastion.assets_dispatcher', :before => :build_middleware_stack do |app|
      app.middleware.use ::ActionDispatch::Static, "#{BastionKatello::Engine.root}/app/assets/javascripts/bastion_katello"
    end

    config.to_prepare do
      consumer_cert_rpm = 'katello-ca-consumer-latest.noarch.rpm'
      consumer_cert_rpm = SETTINGS[:katello][:consumer_cert_rpm] if SETTINGS.key?(:katello)

      db_migrated = !Foreman.in_setup_db_rake? && ActiveRecord::Base.connection.table_exists?(Setting.table_name)

      Bastion.register_plugin(
        :name => 'bastion_katello',
        :javascript => proc do
          [
            javascript_include_tag(*webpack_asset_paths('katello:common', :extension => 'js'), "data-turbolinks-track" => true),
            javascript_include_tag('bastion_katello/bastion_katello')
          ]
        end,
        :stylesheet => 'bastion_katello/bastion_katello',
        :pages => %w(
          activation_keys
          content_credentials
          content_hosts
          content_views
          debs
          docker_tags
          files
          ostree_branches
          errata
          packages
          lifecycle_environments
          products
          puppet_modules
          sync_plans
          host_collections
          katello_tasks
          select_organization
        ),
        :config => {
          'consumerCertRPM' => consumer_cert_rpm,
          'defaultDownloadPolicy' => !Foreman.in_rake? && db_migrated && Setting['default_download_policy'],
          'remoteExecutionPresent' => ::Katello.with_remote_execution?,
          'remoteExecutionByDefault' => ::Katello.with_remote_execution? &&
                                        db_migrated && Setting['remote_execution_by_default']
        }
      )
    end
  end
end
