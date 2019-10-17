module Katello
  module Pulp3
    class DockerManifestList < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpDockerClient::ContentManifestsApi.new(Katello::Pulp3::Repository::Docker.api_client(SmartProxy.pulp_master!))
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Docker.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.content_unit_list(page_opts)
        page_opts[:media_type] = "application/vnd.docker.distribution.manifest.list.v2+json"
        self.content_api.list(page_opts)
      end

      def update_model(model)
        custom_json = {}
        custom_json['schema_version'], = backend_data['schema_version']
        custom_json['digest'], = backend_data['digest']
        custom_json['docker_manifests'] = ::Katello::DockerManifest.where(:pulp_id => backend_data[:listed_manifests])
        model.update_attributes!(custom_json)
      end
    end
  end
end
