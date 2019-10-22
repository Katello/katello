module Katello
  module Pulp3
    class Rpm < PulpContentUnit
      include LazyAccessor

      PULP_INDEXED_FIELDS = %w(name version release arch epoch summary sourcerpm checksum filename is_modular).freeze

      lazy_accessor :description, :license, :buildhost, :vendor, :relativepath, :children, :checksumtype,
                    :changelog, :group, :size, :url, :build_time, :group,
                    :initializer => :backend_data

      def self.content_api
        PulpRpmClient::ContentPackagesApi.new(Katello::Pulp3::Repository::Yum.api_client(SmartProxy.pulp_master!))
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Rpm.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def requires
        if backend_data['requires']
          backend_data['requires'].map { |entry| Katello::Util::Package.format_requires(entry) }.uniq.sort
        else
          []
        end
      end

      def provides
        if backend_data['provides']
          backend_data['provides'].map { |entry| Katello::Util::Package.build_nvrea(entry, false) }.uniq.sort
        else
          []
        end
      end

      def files
        result = []
        if backend_data['files']
          if backend_data['files']['file']
            result << backend_data['files']['file']
          end
          if backend_data['files']['dir']
            result << backend_data['files']['dir']
          end
        end
        result.flatten
      end

      def update_model(model)
        custom_json = {}
        custom_json['modular'] = backend_data['is_modular']
        (PULP_INDEXED_FIELDS - ['is_modular']).each { |field| custom_json[field] = backend_data[field] }
        custom_json['release_sortable'] = Util::Package.sortable_version(backend_data['release'])
        custom_json['version_sortable'] = Util::Package.sortable_version(backend_data['version'])
        custom_json['nvra'] = model.build_nvra
        model.update_attributes!(custom_json)
      end
    end
  end
end
