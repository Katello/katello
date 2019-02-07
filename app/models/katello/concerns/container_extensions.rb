module Katello
  module Concerns
    module ContainerExtensions
      extend ActiveSupport::Concern

      module Overrides
        def repository_pull_url
          repo_url = super
          if Repository.where(:container_repository_name => repository_name).count > 0
            manifest_capsule = self.capsule || SmartProxy.pulp_master
            "#{URI(manifest_capsule.url).hostname}:#{Setting['pulp_docker_registry_port']}/#{repo_url}"
          else
            repo_url
          end
        end
      end

      included do
        prepend Overrides

        belongs_to :capsule, :inverse_of => :containers, :foreign_key => :capsule_id,
          :class_name => "SmartProxy"
      end
    end
  end
end
