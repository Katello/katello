module Actions
  module Pulp
    module Repository
      class Publish < Pulp::Abstract
        input_format do
          param :pulp_id
          param :capsule_id
          param :distributor_type_filter
          param :contents_changed
        end

        def plan(input)
          input[:distributor_type_filter] ||= []

          distributors(input[:pulp_id]).each do |dist|
            # filter only allowed distributors and skip distributors that are published automatically in Pulp
            if input[:distributor_type_filter].include?(dist['distributor_type_id']) && (dist['auto_publish'] == false)
              plan_action(Pulp::Repository::DistributorPublishChanges,
                :pulp_id => input[:pulp_id],
                :capsule_id => input[:capsule_id],
                :distributor_id => dist["id"],
                :contents_changed => input[:contents_changed])
            end
          end
        end

        def distributors(pulp_repo_id)
          repository_details = pulp_extensions.repository.retrieve_with_details(pulp_repo_id)
          repository_details["distributors"]
        end
      end
    end
  end
end
