module Actions
  module Pulp
    module Consumer
      class UnassociateUnits < ::Actions::Pulp::AbstractAsyncTask
        input_format do
          param :capsule_id, Integer
          param :repo_pulp_id, String
        end

        def plan(repository, smart_proxy, _options)
          plan_self(:capsule_id => smart_proxy.id, :repo_pulp_id => repository.pulp_id)
        end

        def humanized_name
          _("Unassociate units in repository")
        end

        def invoke_external_task
          pulp_resources.repository.unassociate_units(input[:repo_pulp_id])
        end
      end
    end
  end
end
