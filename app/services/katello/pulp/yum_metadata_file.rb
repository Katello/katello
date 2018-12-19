module Katello
  module Pulp
    class YumMetadataFile < PulpContentUnit
      CONTENT_TYPE = "yum_repo_metadata_file".freeze
    end
  end
end
