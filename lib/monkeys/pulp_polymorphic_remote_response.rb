# Pulpcore 3.90+ AsyncUpdateMixin bug workaround
#
# update/partial_update endpoints return either HTTP 202 {"task": "..."} when changes
# are detected, or HTTP 200 with the resource when nothing changed. At the moment, the
# Pulp Ruby bindings drop the task data from the response.
#
# This patch forces debug_return_type to AsyncOperationResponse on all update methods
# so the 202 body deserializes correctly. On 200 (no-op), AsyncOperationResponse gets
# task=nil, which callers already handle.
#
# Remove when pulpcore fixes the schema for AsyncUpdateMixin endpoints:
# https://github.com/pulp/pulpcore/issues/7705

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

# Every API class whose ViewSet inherits AsyncUpdateMixin must be listed here.
# When adding new Pulp plugins or bumping gem versions, verify coverage.
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
  PulpDebClient::RemotesAptApi,
  PulpFileClient::RemotesFileApi,
  PulpPythonClient::RemotesPythonApi,
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
