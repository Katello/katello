module Katello
  module Pulp3
    class DockerBlob < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpContainerClient::ContentBlobsApi.new(Katello::Pulp3::Api::Docker.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Docker.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end
    end
  end
end
