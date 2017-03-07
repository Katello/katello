module Actions
  module Pulp
    module ContentViewPuppetEnvironment
      class IndexContent < Pulp::Abstract
        input_format do
          param :id, Integer
        end

        def run
          User.as_anonymous_admin do
            puppet_env = ::Katello::ContentViewPuppetEnvironment.find(input[:id])
            puppet_module_ids = pulp_extensions.repository.puppet_module_ids(puppet_env.pulp_id)
            puppet_env.index_content(puppet_module_ids)
          end
        end
      end
    end
  end
end
