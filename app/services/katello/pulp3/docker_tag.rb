module Katello
  module Pulp3
    class DockerTag < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "docker_tag".freeze

      def self.content_api
        PulpContainerClient::ContentTagsApi.new(Katello::Pulp3::Api::Docker.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Docker.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def update_model(model)
        custom_json = {}
        taggable = ::Katello::DockerManifest.find_by(:pulp_id => backend_data['tagged_manifest'])
        if taggable.nil?
          taggable = ::Katello::DockerManifestList.find_by(:pulp_id => backend_data['tagged_manifest'])
        end
        custom_json['docker_taggable'] = taggable
        custom_json['name'] = backend_data['name']
        model.update!(custom_json)
      end
    end
  end
end
