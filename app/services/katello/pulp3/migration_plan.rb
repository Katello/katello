module Katello
  module Pulp3
    class MigrationPlan
      def initialize(repository_type_labels)
        @repository_types = repository_type_labels
      end

      def generate
        plan = {}
        plan[:plugins] = generate_plugins
        plan
      end

      def generate_plugins
        @repository_types.map do |repository_type|
          {
            type: pulp2_repository_type(repository_type)
          }
        end
      end

      def pulp2_repository_type(repository_type)
        Katello::RepositoryTypeManager.repository_types[repository_type].service_class::REPOSITORY_TYPE
      end
    end
  end
end
