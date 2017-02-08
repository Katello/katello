module Actions
  module Pulp
    module Repository
      class DistributorPublish < Pulp::AbstractAsyncTask
        middleware.use Actions::Middleware::SkipIfMatchingContent

        input_format do
          param :pulp_id
          param :distributor_type_id
          param :source_pulp_id
          param :dependency
          param :override_config
          param :matching_content
        end

        def invoke_external_task
          pulp_extensions.repository.
              publish(input[:pulp_id],
                      distributor_id(input[:pulp_id], input[:distributor_type_id]),
                      distributor_config)
        end

        def distributor_id(pulp_id, distributor_type_id)
          distributor = repo(pulp_id)["distributors"].find do |dist|
            dist["distributor_type_id"] == distributor_type_id
          end
          distributor['id']
        end

        def distributor_config
          # the check for YumCloneDistributor is here for backwards compatibility
          if input[:distributor_type_id] == Runcible::Models::YumCloneDistributor.type_id
            { override_config: { source_repo_id: input[:source_pulp_id],
                                 source_distributor_id: source_distributor_id} }
          else
            { override_config: input[:override_config] }
          end
        end

        def source_distributor_id
          distributor_id(input[:source_pulp_id], Runcible::Models::YumDistributor.type_id)
        end

        def repo(pulp_id)
          pulp_extensions.repository.retrieve_with_details(pulp_id)
        end

        def humanized_name
          _("Repository metadata publish")
        end
      end
    end
  end
end
