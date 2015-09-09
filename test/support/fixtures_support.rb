module Katello
  module FixturesSupport
    FIXTURE_CLASSES = {
      :katello_activation_keys => "Katello::ActivationKey",
      :katello_content_views => "Katello::ContentView",
      :katello_content_view_environments => "Katello::ContentViewEnvironment",
      :katello_content_view_filters => "Katello::ContentViewFilter",
      :katello_content_view_erratum_filter_rules => "Katello::ContentViewErratumFilterRule",
      :katello_content_view_package_filter_rules => "Katello::ContentViewPackageFilterRule",
      :katello_content_view_package_group_filter_rules => "Katello::ContentViewPackageGroupFilterRule",
      :katello_content_view_puppet_modules => "Katello::ContentViewPuppetModule",
      :katello_content_view_puppet_environments => "Katello::ContentViewPuppetEnvironment",
      :katello_content_view_repositories => "Katello::ContentViewRepository",
      :katello_content_view_version_environments => "Katello::ContentViewVersionEnvironment",
      :katello_content_view_versions => "Katello::ContentViewVersion",
      :katello_distributors => "Katello::Distributor",
      :katello_environment_priors => "Katello::EnvironmentPrior",
      :katello_environments => "Katello::KTEnvironment",
      :katello_gpg_keys => "Katello::GpgKey",
      :katello_package_groups => "Katello::PackageGroup",
      :katello_repository_package_groups => "Katello::RepositoryPackageGroup",
      :katello_products => "Katello::Product",
      :katello_providers => "Katello::Provider",
      :katello_repositories => "Katello::Repository",
      :katello_sync_plans => "Katello::SyncPlan",
      :katello_host_collections => "Katello::HostCollection",
      :katello_systems => "Katello::System",
      :katello_system_host_collections => "Katello::SystemHostCollection",
      :katello_task_statuses => "Katello::TaskStatus",
      :katello_errata => "Katello::Erratum",
      :katello_erratum_packages => "Katello::ErratumPackage",
      :katello_erratum_cves => "Katello::ErratumCve",
      :katello_repository_errata => "Katello::RepositoryErratum",
      :katello_rpms => "Katello::Rpm",
      :katello_repository_rpms => "Katello::RepositoryRpm",
      :katello_system_errata => "Katello::SystemErratum"
    }

    # rubocop:disable Style/AccessorMethodName
    def self.set_fixture_classes(test_class)
      FIXTURE_CLASSES.each { |k, v| test_class.set_fixture_class(k => v) }
    end
  end
end
