module Katello
  module Pulp3
    class DockerManifest < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpContainerClient::ContentManifestsApi.new(Katello::Pulp3::Api::Docker.new(SmartProxy.pulp_master!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Docker.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.content_unit_list(page_opts)
        page_opts[:media_type] = "application/vnd.docker.distribution.manifest.v1+json"
        data_v1 = self.content_api.list(page_opts)
        page_opts[:media_type] = "application/vnd.docker.distribution.manifest.v2+json"
        data_v2 = self.content_api.list(page_opts)

        filtered = {}
        filtered["count"] = data_v1.count + data_v2.count
        filtered["results"] = data_v1.results + data_v2.results
        filtered
      end

      def update_model(model)
        custom_json = {}
        custom_json['schema_version'], = backend_data['schema_version']
        custom_json['digest'], = backend_data['digest']
        model.update_attributes!(custom_json)
      end
    end
  end
end
