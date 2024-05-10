require 'pulp_ostree_client'

Katello::RepositoryTypeManager.register('ostree') do
  allow_creation_by_user true
  pulp3_service_class Katello::Pulp3::Repository::Generic
  pulp3_api_class Katello::Pulp3::Api::Generic
  pulp3_plugin 'ostree'
  pulp3_skip_publication true

  client_module_class PulpOstreeClient
  api_class PulpOstreeClient::ApiClient
  configuration_class PulpOstreeClient::Configuration
  remote_class PulpOstreeClient::OstreeOstreeRemote
  remotes_api_class PulpOstreeClient::RemotesOstreeApi
  repositories_api_class PulpOstreeClient::RepositoriesOstreeApi
  repository_versions_api_class PulpOstreeClient::RepositoriesOstreeVersionsApi
  distributions_api_class PulpOstreeClient::DistributionsOstreeApi
  distribution_class PulpOstreeClient::OstreeOstreeDistribution
  repo_sync_url_class PulpOstreeClient::RepositorySyncURL

  generic_remote_option :include_refs, title: N_("Include Refs"), type: Array, input_type: "text", delimiter: ",", default: [],
                         description: N_("A comma-separated list of refs to include during a sync. The wildcards *, ? are recognized.")

  generic_remote_option :exclude_refs, title: N_("Exclude Refs"), type: Array, input_type: "text", delimiter: ",", default: [],
                         description: N_("A comma-separated list of tags to exclude during a sync. The wildcards *, ? are recognized. 'exclude_refs' is evaluated after 'include_refs'.")

  url_description N_("URL of an OSTree repository.")

  generic_content_type 'ostree_ref',
                       pluralized_name: "OSTree Refs",
                       pulpcore_name: "ostree.refs",
                       model_class: Katello::GenericContentUnit,
                       pulp3_api: PulpOstreeClient::ContentRefsApi,
                       pulp3_service_class: Katello::Pulp3::GenericContentUnit,
                       model_name: lambda { |pulp_unit| pulp_unit["name"] },
                       model_version: lambda { |pulp_unit| pulp_unit["checksum"] },
                       uploadable: true,
                       generic_browser: true,
                       repository_import_on_upload: true

  import_attribute :ref, :content_type => 'ostree_ref',
                        :api_param => :ostree_ref,
                        :description => "OSTree ref branch that holds the reference to the last commit",
                        :type => String,
                        :required => false

  import_attribute :repository_name, :content_type => 'ostree_ref',
                        :api_param => :ostree_repository_name,
                        :description => "Name of the repository in the ostree archive",
                        :type => String,
                        :required => true

  default_managed_content_type :ostree_ref

  test_url 'https://fixtures.pulpproject.org/ostree/small/'
  test_url_root_options generic_remote_options: {include_refs: ['rawhide']}.to_json
end
