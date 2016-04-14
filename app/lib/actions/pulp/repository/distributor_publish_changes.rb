module Actions
  module Pulp
    module Repository
      class DistributorPublishChanges < DistributorPublish
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        input_format do
          param :pulp_id
          param :distributor_id
          param :distributor_type_id
          param :source_pulp_id
          param :dependency
          param :override_config
          param :contents_changed
        end
      end
    end
  end
end
