module Katello
  module Pulp3
    class FileUnit < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "iso".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::File.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:_href) }
      end

      def self.pulp_data(href)
        content_unit = SmartProxy.pulp_master!.pulp3_api.content_file_files_read(href)
        content_unit.as_json
      end

      def update_model(model)
        custom_json = {}
        custom_json['checksum'] = backend_data['sha256']
        custom_json['path'] = backend_data['relative_path']
        custom_json['name'] = File.basename(backend_data['relative_path'].try(:split, '/').try(:[], -1))
        model.update_attributes!(custom_json)
      end

      def self.pulp_units_batch_for_repo(repository, page_size = SETTINGS[:katello][:pulp][:bulk_load_size])
        repository_version_href = repository.version_href
        page_opts = { "page" => 1, repository_version: repository_version_href, page_size: page_size}
        response = {}
        Enumerator.new do |yielder|
          loop do
            page_opts = page_opts.with_indifferent_access
            break unless (response["next"] || page_opts["page"] == 1)
            response = SmartProxy.pulp_master!.pulp3_api.content_file_files_list page_opts
            response = response.as_json.with_indifferent_access
            yielder.yield response[:results]
            page_opts[:page] += 1
          end
        end
      end
    end
  end
end
