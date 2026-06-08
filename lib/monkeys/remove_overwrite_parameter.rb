# Monkey patch to remove the 'overwrite' parameter from RepositoryAddRemoveContent
#
# The pulp_rpm_client gem 3.35.3 includes an 'overwrite' parameter that was added
# in a newer Pulp RPM version (3.37.0+), but the current Pulp server doesn't support it yet.
# This patch removes the parameter from the serialized hash to maintain compatibility.

module PulpRpmClient
  class RepositoryAddRemoveContent
    # Override to_hash to exclude 'overwrite' parameter
    alias_method :original_to_hash, :to_hash

    def to_hash
      hash = original_to_hash
      hash.delete(:overwrite)
      hash.delete('overwrite')
      hash
    end
  end
end
