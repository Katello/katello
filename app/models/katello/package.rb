module Katello
  class Package
    include Glue::Pulp::Package if Katello.config.use_pulp
    include Glue::ElasticSearch::Package if Katello.config.use_elasticsearch
    CONTENT_TYPE = "rpm"
  end
end
