module Actions
  module Pulp3
    module Orchestration
      module Repository
        class GenerateMetadata < Pulp3::Abstract
          def plan(repository, smart_proxy, options = {})
            options[:contents_changed] = (options && options.key?(:contents_changed)) ? options[:contents_changed] : true
            sequence do
              plan_action(Actions::Pulp3::Repository::CreateVersion, repository, smart_proxy) if options[:repository_creation]
              plan_action(Actions::Pulp3::Repository::CreatePublication, repository, smart_proxy, options)
              plan_action(Actions::Pulp3::Repository::RefreshDistribution, repository, smart_proxy, :contents_changed => options[:contents_changed])
            end
          end
        end
      end
    end
  end
end
