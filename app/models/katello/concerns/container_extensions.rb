module Katello
  module Concerns
    module ContainerExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :capsule, :inverse_of => :containers, :foreign_key => :capsule_id,
          :class_name => "SmartProxy"

        alias_method_chain :repository_pull_url, :katello
      end

      def repository_pull_url_with_katello
        repo_url = repository_pull_url_without_katello
        if Repository.where(:container_repository_name => repository_name).count > 0
          manifest_capsule = self.capsule || CapsuleContent.default_capsule.capsule
          "#{URI(manifest_capsule.url).hostname}:#{Setting['pulp_docker_registry_port']}/#{repo_url}"
        else
          repo_url
        end
      end
    end
  end
end
