module Actions
  module Katello
    module CapsuleContent
      class RemoveOrphans < Pulp::Abstract
        input_format do
          param :capsule_id
        end

        def run
          pulp_resources.content.remove_orphans
        end
      end
    end
  end
end
