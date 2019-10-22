module Katello
  module Pulp3
    class Distribution < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpRpmClient::ContentDistributionTreesApi.new(Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_master!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end
    end
  end
end
