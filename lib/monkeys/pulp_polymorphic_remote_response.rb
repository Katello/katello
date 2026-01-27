# TODO: *** remove this after Katello upgrades to Pulpcore 3.90+ ***
#
# Monkey patch to handle Pulpcore 3.90+ polymorphic Remote update responses
#
# Background:
# Pulpcore 3.90 introduced polymorphic responses on Remote update endpoints
# (see https://github.com/pulp/pulpcore/pull/6953):
# - HTTP 202 with AsyncOperationResponse {task: "task_href"} when changes detected
# - HTTP 204 (no content) when no changes detected
#
# This optimization skips task dispatch when Remote update requests contain no
# actual changes to the resource.
#
# Problem:
# Katello currently uses Pulpcore 3.85, but Ruby bindings were generated with Pulpcore 3.90+.
# The plugin bindings (pulp_rpm_client 3.32.3+, etc.) were generated with the
# polymorphic schema but ended up with incorrect default return types.
#
# What happens without this patch:
# - Pulpcore 3.85 returns HTTP 202 with {task: "/pulp/api/v3/tasks/..."}
# - Bindings try to deserialize this into RpmRpmRemoteResponse
# - Result: RpmRpmRemoteResponse object with all nil attributes
#   Example: [#<PulpRpmClient::RpmRpmRemoteResponse @name=nil, @url=nil>]
#   (See https://github.com/pulp/pulp_rpm/issues/4178)
#
# Solution:
# Patch Remote API classes (RemotesRpmApi, RemotesAnsibleApi, etc.) to override
# the _with_http_info methods for partial_update and update. Force the expected
# return_type from XxxRemoteResponse to AsyncOperationResponse by setting the
# debug_return_type option before calling the original method.
#
# References:
# - Pulpcore PR: https://github.com/pulp/pulpcore/pull/6953
# - Issue report: https://github.com/pulp/pulp_rpm/issues/4178

require 'pulp_rpm_client'
require 'pulp_file_client'
require 'pulp_ansible_client'
require 'pulp_container_client'
require 'pulp_deb_client'
require 'pulp_python_client'
require 'pulp_ostree_client'
require 'pulpcore_client'

# Helper module to patch Remote API classes
module PulpPolymorphicRemoteResponsePatch
  # Patch a Remote API class's update methods to return AsyncOperationResponse
  def self.patch_remote_method(klass, method_name)
    # We need to patch the _with_http_info method since that's where return_type is set
    with_http_info_method = :"#{method_name}_with_http_info"

    klass.class_eval do
      # Save reference to original _with_http_info method
      original_method = :"#{with_http_info_method}_original"
      alias_method original_method, with_http_info_method

      # Override the _with_http_info method to force AsyncOperationResponse return type
      define_method(with_http_info_method) do |href, data, opts = {}|
        # The generated bindings code uses: return_type = opts[:debug_return_type] || 'RpmRpmRemoteResponse' for example
        # By setting debug_return_type to AsyncOperationResponse, we override the default
        modified_opts = (opts || {}).merge(debug_return_type: 'AsyncOperationResponse')

        # Call original method with modified opts
        send(original_method, href, data, modified_opts)
      end
    end
  end
end

# Patch all Remote API classes that need polymorphic response handling
# Note: File, Deb, and Python clients already expect AsyncOperationResponse in their bindings
[
  PulpRpmClient::RemotesRpmApi,
  PulpRpmClient::RemotesUlnApi,
  PulpAnsibleClient::RemotesCollectionApi,
  PulpAnsibleClient::RemotesGitApi,
  PulpAnsibleClient::RemotesRoleApi,
  PulpContainerClient::RemotesContainerApi,
  PulpContainerClient::RemotesPullThroughApi,
  PulpOstreeClient::RemotesOstreeApi,
].each do |klass|
  [:partial_update, :update].each do |method|
    PulpPolymorphicRemoteResponsePatch.patch_remote_method(klass, method)
  end
end
