module Actions
  module Pulp
    module RepositoryGroup
      class Delete < Pulp::Abstract
        include Helpers::Presenter

        input_format do
          param :id
        end

        def run
          pulp_resources.repository_group.delete(input[:id])
        end
      end
    end
  end
end
