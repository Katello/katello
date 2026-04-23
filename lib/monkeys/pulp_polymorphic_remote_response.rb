# Monkey patch to handle Pulpcore 3.90+ polymorphic update responses (PULP-734)
#
# Pulpcore 3.90+ introduced polymorphic responses on all update endpoints via AsyncUpdateMixin
# (see https://github.com/pulp/pulpcore/commit/c8ca610a4e968c10fde8bf607b9f384f892d216c):
# - HTTP 202 with AsyncOperationResponse {task: "task_href"} when changes detected
# - HTTP 200 with resource response when no changes detected
#
# This optimization (tracked in PULP-734) skips task dispatch when update requests contain
# no actual changes to the resource. We must patch all affected API classes to override the
# _with_http_info methods for partial_update and update. Force the expected return_type from
# XxxResponse to AsyncOperationResponse by setting the debug_return_type option before calling
# the original method.

require 'pulp_rpm_client'
require 'pulp_file_client'
require 'pulp_ansible_client'
require 'pulp_container_client'
require 'pulp_deb_client'
require 'pulp_python_client'
require 'pulp_ostree_client'
require 'pulpcore_client'

module PulpPolymorphicResponsePatch
  def self.patch_update_method(klass, method_name)
    with_http_info_method = :"#{method_name}_with_http_info"

    klass.class_eval do
      # Save reference to original _with_http_info method
      original_method = :"#{with_http_info_method}_original"
      alias_method original_method, with_http_info_method

      # Override the _with_http_info method to force AsyncOperationResponse return type
      define_method(with_http_info_method) do |href, data, opts = {}|
        # The generated bindings code uses: return_type = opts[:debug_return_type] || 'RpmRpmRemoteResponse'
        # By setting debug_return_type to AsyncOperationResponse, we override the default
        modified_opts = (opts || {}).merge(debug_return_type: 'AsyncOperationResponse')

        # Call original method with modified opts
        send(original_method, href, data, modified_opts)
      end
    end
  end
end

# Apply patches to all affected ViewSets (via AsyncUpdateMixin)
# Note: File, Deb, and Python remote clients already expect AsyncOperationResponse in their bindings
[
  # RemoteViewSet
  PulpRpmClient::RemotesRpmApi,
  PulpRpmClient::RemotesUlnApi,
  PulpAnsibleClient::RemotesCollectionApi,
  PulpAnsibleClient::RemotesGitApi,
  PulpAnsibleClient::RemotesRoleApi,
  PulpContainerClient::RemotesContainerApi,
  PulpContainerClient::RemotesPullThroughApi,
  PulpOstreeClient::RemotesOstreeApi,
  # RepositoryViewSet
  PulpRpmClient::RepositoriesRpmApi,
  PulpFileClient::RepositoriesFileApi,
  PulpAnsibleClient::RepositoriesAnsibleApi,
  PulpContainerClient::RepositoriesContainerApi,
  PulpContainerClient::RepositoriesContainerPushApi,
  PulpDebClient::RepositoriesAptApi,
  PulpPythonClient::RepositoriesPythonApi,
  PulpOstreeClient::RepositoriesOstreeApi,
  # DistributionViewSet
  PulpRpmClient::DistributionsRpmApi,
  PulpFileClient::DistributionsFileApi,
  PulpAnsibleClient::DistributionsAnsibleApi,
  PulpContainerClient::DistributionsContainerApi,
  PulpContainerClient::DistributionsPullThroughApi,
  PulpDebClient::DistributionsAptApi,
  PulpPythonClient::DistributionsPypiApi,
  PulpOstreeClient::DistributionsOstreeApi,
  # AlternateContentSourceViewSet
  PulpRpmClient::AcsRpmApi,
  PulpFileClient::AcsFileApi,
  PulpDebClient::AcsDebApi,
  # ExporterViewSet
  PulpcoreClient::ExportersFilesystemApi,
  PulpcoreClient::ExportersPulpApi,
].each do |klass|
  [:partial_update, :update].each do |method|
    PulpPolymorphicResponsePatch.patch_update_method(klass, method)
  end
end
