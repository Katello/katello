module Katello
  class PackageGroup
    include Glue::Pulp::PackageGroup if Katello.config.use_pulp
    include Glue::ElasticSearch::PackageGroup if Katello.config.use_elasticsearch
    CONTENT_TYPE = "package_group"
  end
end
