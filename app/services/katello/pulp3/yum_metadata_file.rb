module Katello
  module Pulp3
    class YumMetadataFile < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpRpmClient::ContentRepoMetadataFilesApi.new(Katello::Pulp3::Repository::Yum.api_client(SmartProxy.pulp_master!))
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      # TODO: The Pulp 3 Yum Metadata File API doesn't expose names or file paths yet.
      # Need to decide if we'll still index Yum Metadata Files in Pulp 3.
    end
  end
end
