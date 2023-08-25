module Katello
  module Pulp3
    class DockerManifestList < PulpContentUnit
      include LazyAccessor
      PULPCORE_CONTENT_TYPE = "container.manifest".freeze

      def self.content_api(smart_proxy = SmartProxy.pulp_primary!)
        PulpContainerClient::ContentManifestsApi.new(Katello::Pulp3::Api::Docker.new(smart_proxy).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Docker.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.page_options(page_opts = {})
        page_opts[:media_type] = ['application/vnd.docker.distribution.manifest.list.v2+json',
                                  'application/vnd.oci.image.index.v1+json']
        page_opts
      end

      def self.content_unit_list(page_opts = {})
        self.content_api.list(self.page_options(page_opts))
      end

      def self.generate_model_row(unit)
        {
          schema_version: unit['schema_version'],
          digest: unit['digest'],
          pulp_id: unit[unit_identifier]
        }
      end

      def self.insert_child_associations(units, pulp_id_to_id)
        manifest_list_manifests = []
        units.each do |unit|
          katello_id = pulp_id_to_id[unit[unit_identifier]]
          manifest_ids = ::Katello::DockerManifest.where(:pulp_id => unit[:listed_manifests]).pluck(:id)
          manifest_list_manifests += manifest_ids.map do |manifest_id|
            {
              docker_manifest_list_id: katello_id,
              docker_manifest_id: manifest_id
            }
          end
        end

        manifest_list_manifests.flatten!
        Katello::DockerManifestListManifest.insert_all(manifest_list_manifests, unique_by: [:docker_manifest_list_id, :docker_manifest_id]) if manifest_list_manifests.any?
      end
    end
  end
end
