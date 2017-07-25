module Katello
  module FixturesSupport
    FIXTURE_CLASSES = {
      :katello_activation_keys => Katello::ActivationKey,
      :katello_content_views => Katello::ContentView,
      :katello_content_view_environments => Katello::ContentViewEnvironment,
      :katello_content_view_filters => Katello::ContentViewFilter,
      :katello_content_view_erratum_filter_rules => Katello::ContentViewErratumFilterRule,
      :katello_content_view_package_filter_rules => Katello::ContentViewPackageFilterRule,
      :katello_content_view_package_group_filter_rules => Katello::ContentViewPackageGroupFilterRule,
      :katello_content_view_puppet_modules => Katello::ContentViewPuppetModule,
      :katello_content_view_puppet_environments => Katello::ContentViewPuppetEnvironment,
      :katello_content_view_repositories => Katello::ContentViewRepository,
      :katello_content_view_histories => Katello::ContentViewHistory,
      :katello_content_view_versions => Katello::ContentViewVersion,
      :katello_environments => Katello::KTEnvironment,
      :katello_files => Katello::FileUnit,
      :katello_gpg_keys => Katello::GpgKey,
      :katello_package_groups => Katello::PackageGroup,
      :katello_repository_package_groups => Katello::RepositoryPackageGroup,
      :katello_pools => Katello::Pool,
      :katello_products => Katello::Product,
      :katello_providers => Katello::Provider,
      :katello_puppet_modules => Katello::PuppetModule,
      :katello_repository_puppet_modules => Katello::RepositoryPuppetModule,
      :katello_repositories => Katello::Repository,
      :katello_sync_plans => Katello::SyncPlan,
      :katello_host_collections => Katello::HostCollection,
      :katello_subscriptions => Katello::Subscription,
      :katello_host_collection_hosts => Katello::HostCollectionHosts,
      :katello_task_statuses => Katello::TaskStatus,
      :katello_errata => Katello::Erratum,
      :katello_erratum_packages => Katello::ErratumPackage,
      :katello_erratum_cves => Katello::ErratumCve,
      :katello_repository_errata => Katello::RepositoryErratum,
      :katello_rpms => Katello::Rpm,
      :katello_repository_rpms => Katello::RepositoryRpm,
      :katello_content_facets => Katello::Host::ContentFacet,
      :katello_subscription_facets => Katello::Host::SubscriptionFacet,
      :katello_docker_manifests => Katello::DockerManifest,
      :katello_docker_tags => Katello::DockerTag,
      :katello_subscription_facet_pools => Katello::SubscriptionFacetPool
    }.freeze

    # rubocop:disable Style/AccessorMethodName
    def self.set_fixture_classes(test_class)
      FIXTURE_CLASSES.each { |k, v| test_class.set_fixture_class(k => v) }
    end
  end
end
