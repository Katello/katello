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

      def self.generate_model_row(unit)
        row = {
          pulp_id: unit[unit_identifier],
          name: unit['name']
        }

        taggable = ::Katello::DockerManifest.find_by(:pulp_id => unit['tagged_manifest'])
        taggable_type = ::Katello::DockerManifest.name
        if taggable.nil?
          taggable = ::Katello::DockerManifestList.find_by(:pulp_id => unit['tagged_manifest'])
          taggable_type = ::Katello::DockerManifestList.name
        end

        if taggable
          row[:docker_taggable_id] = taggable.id
          row[:docker_taggable_type] = taggable_type
        end
        row
      end
    end
  end
end
