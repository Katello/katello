module Katello
  module Pulp3
    class Rpm < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "rpm".freeze

      PULP_INDEXED_FIELDS = %w(pulp_href name version release arch epoch summary is_modular rpm_sourcerpm location_href pkgId).freeze

      lazy_accessor :description, :license, :buildhost, :vendor, :relativepath, :children, :checksumtype,
                    :changelog, :group, :size, :url, :build_time, :group,
                    :initializer => :backend_data

      def self.content_api
        PulpRpmClient::ContentPackagesApi.new(Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.page_options(page_opts = {})
        page_opts["arch__ne"] = "src"
        page_opts
      end

      def requires
        Util::Package.parse_dependencies(backend_data['requires'])
      end

      def provides
        Util::Package.parse_dependencies(backend_data['provides'])
      end

      def files
        files = backend_data['files'].collect do |file_and_path|
          # First item in the array might be a directive like "dir" or "ghost"
          if file_and_path[0][0] != '/'
            file_and_path.shift
          end
          file_and_path.join('')
        end

        files.uniq
      end

      def buildhost
        backend_data['rpm_buildhost']
      end

      def vendor
        backend_data['rpm_vendor']
      end

      def relativepath
        backend_data['location_href']
      end

      def checksumtype
        backend_data['checksum_type']
      end

      def changelog
        backend_data['changelogs']
      end

      def group
        backend_data['rpm_group']
      end

      def build_time
        backend_data['time_build']
      end

      def size
        backend_data['size_package']
      end

      def license
        backend_data['rpm_license']
      end

      def self.parse_filename(path)
        File.split(path).last unless path.blank?
      end

      def self.generate_model_row(unit)
        custom_json = {}
        custom_json['modular'] = unit['is_modular']
        custom_json['pulp_id'] = unit['pulp_href']
        (PULP_INDEXED_FIELDS - ['is_modular', 'pulp_href', 'rpm_sourcerpm', 'pkgId', 'location_href']).
          each { |field| custom_json[field] = unit[field] }
        custom_json['release_sortable'] = Util::Package.sortable_version(unit['release'])
        custom_json['version_sortable'] = Util::Package.sortable_version(unit['version'])
        custom_json['filename'] = parse_filename(unit['location_href']) #location_href is the relative path of the rpm in the upstream repo
        custom_json['checksum'] = unit['pkgId']
        custom_json['sourcerpm'] = unit['rpm_sourcerpm']
        custom_json['nvra'] = Util::Package.build_nvra(custom_json.with_indifferent_access)
        custom_json['summary'] = custom_json['summary']&.truncate(255)
        custom_json
      end
    end
  end
end
