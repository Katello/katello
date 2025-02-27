module Katello
  module Pulp3
    class DockerManifest < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "docker_manifest".freeze
      PULPCORE_CONTENT_TYPE = "container.manifest".freeze

      def self.content_api
        PulpContainerClient::ContentManifestsApi.new(Katello::Pulp3::Api::Docker.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Docker.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.content_unit_list(page_opts)
        page_opts[:media_type] = ['application/vnd.docker.distribution.manifest.v1+json',
                                  'application/vnd.docker.distribution.manifest.v2+json',
                                  'application/vnd.oci.image.manifest.v1+json']
        self.content_api.list(page_opts)
      end

      def self.generate_model_row(unit)
        {
          schema_version: unit['schema_version'],
          digest: unit['digest'],
          pulp_id: unit[unit_identifier],
          annotations: unit['annotations'],
          labels: unit['labels'],
          is_bootable: unit['is_bootable'] || unit['type'] == 'bootable',
          is_flatpak: unit['is_flatpak'] || unit['type'] == 'flatpak',
          content_type: unit['type'],
        }
      end
    end
  end
end
