module Actions
  module Pulp
    module Consumer
      class AbstractNodeDistributorTask <  Pulp::AbstractAsyncTask
        def invoke_external_task
          fail NotImplementedError
        end

        protected

        def distributor
          @distributor ||= repo_details['distributors'].find do |distributor|
            distributor["distributor_type_id"] == Runcible::Models::NodesHttpDistributor.type_id
          end
          unless @distributor
            fail "Could not find node distributor for repository %s" % input[:repo_id]
          end
          @distributor
        end

        def repo_details
          pulp_extensions.repository.retrieve_with_details(input[:repo_id])
        end
      end
    end
  end
end
