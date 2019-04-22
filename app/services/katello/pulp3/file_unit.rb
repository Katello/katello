module Katello
  module Pulp3
    class FileUnit < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "iso".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::File.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map {| content| content.try(:_href) }
      end

      def self.pulp_data(href)
        content_unit = SmartProxy.pulp_master!.pulp3_api.content_file_files_read(href)
        content_unit_json = {}
        if content_unit
          content_unit_json = content_unit.as_json
          artifact_href = content_unit_json["_artifact"]
          artifact_data = SmartProxy.pulp_master!.pulp3_api.artifacts_read(artifact_href)
          if artifact_data
            content_unit_json["checksum"] = artifact_data.as_json["sha256"]
          end
          content_unit_json
        end
      end

      def update_model(model)
        custom_json = {}
        custom_json['checksum'] = backend_data['checksum']
        custom_json['path'] = backend_data['relative_path']
        custom_json['name'] = File.basename(backend_data['relative_path'].try(:split, '/').try(:[], -1))
        model.update_attributes!(custom_json)
      end
    end
  end
end
