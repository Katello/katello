# Monkey patch to drop request fields that newer Pulp bindings send by default
# but older Pulp servers reject with {"<field>": ["Unexpected field"]}.
#
# The generated bindings assign a client-side default to these fields in their
# initializer, so they end up in the request body even though Katello never
# sets them. Each entry below removes the default when (and only when) the
# caller did not pass the field explicitly, which keeps the same bindings
# usable against both the oldest supported Pulp and current Pulp.
#
# When Katello drops support for the Pulp version that rejects a field, remove
# that entry here so the field can be used again.

require 'pulpcore_client'
require 'pulp_rpm_client'
require 'pulp_file_client'
require 'pulp_deb_client'
require 'pulp_ansible_client'
require 'pulp_python_client'
require 'pulp_ostree_client'

module Katello
  module RemoveUnsupportedBindingDefaults
    # Prepends an initializer to +klass+ that unsets each of +attributes+ that
    # the binding defaulted rather than the caller supplying it. The attribute
    # has to be unset (not set to nil), since to_hash emits an explicit null
    # for nullable attributes whose instance variable is defined.
    def self.patch(klass, *attributes)
      klass.prepend(Module.new do
        define_method(:initialize) do |attrs = {}|
          super(attrs)

          supplied = attrs.is_a?(Hash) ? attrs.keys.map(&:to_sym) : []
          (attributes - supplied).each do |attribute|
            ivar = :"@#{attribute}"
            remove_instance_variable(ivar) if instance_variable_defined?(ivar)
          end
        end
      end)
    end
  end
end

# overwrite on the repository modify endpoints. pulp_rpm has shipped it for a
# while (this supersedes the old pulp_rpm-only patch), the other plugins picked
# it up in the bindings Katello now requires.
[
  PulpcoreClient::RepositoryAddRemoveContent,
  PulpRpmClient::RepositoryAddRemoveContent,
  PulpFileClient::RepositoryAddRemoveContent,
  PulpDebClient::AptRepositoryAddRemoveContent,
  PulpAnsibleClient::RepositoryAddRemoveContent,
  PulpPythonClient::RepositoryAddRemoveContent,
  PulpOstreeClient::RepositoryAddRemoveContent,
].each do |klass|
  Katello::RemoveUnsupportedBindingDefaults.patch(klass, :overwrite)
end

# dependency_upgrade on the rpm copy endpoint.
Katello::RemoveUnsupportedBindingDefaults.patch(PulpRpmClient::Copy, :dependency_upgrade)

# publish_legacy_release_files on apt publications.
Katello::RemoveUnsupportedBindingDefaults.patch(PulpDebClient::DebAptPublication, :publish_legacy_release_files)

# pulp_file replaced core's RepositorySyncURL with FileRepositorySyncURL, which
# defaults optimize; older pulp_file's sync endpoint has no such field. mirror
# is supported there, and Katello always passes it explicitly.
Katello::RemoveUnsupportedBindingDefaults.patch(PulpFileClient::FileRepositorySyncURL, :optimize)
