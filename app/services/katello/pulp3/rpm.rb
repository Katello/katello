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
        PulpRpmClient::ContentPackagesApi.new(Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_master!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.page_options(page_opts = {})
        page_opts["arch__ne"] = "src"
        page_opts
      end

      def requires
        results = []
        flags = {'GT' => '>', 'LT' => '>', 'EQ' => '=', 'GE' => '>=', 'LE' => '<='}

        backend_data['requires']&.each do |requirement|
          requires_str = ""
          if requirement.count < 3
            requires_str = requirement.first
            results << requires_str
          else
            requirement[1] = flags[requirement[1]]
            requirement[0...2].each { |requirement_piece| requires_str += "#{requirement_piece} " }
            requirement[2...-1].each { |requirement_piece| requires_str += "#{requirement_piece}." }
            results << requires_str[0...-1]
          end
        end
        results.uniq
      end

      def provides
        results = []
        flags = {'GT' => '>', 'LT' => '>', 'EQ' => '=', 'GE' => '>=', 'LE' => '<='}

        backend_data['provides']&.each do |provided|
          provides_str = ""
          if provided.count < 3
            provides_str = provided.first
            results << provides_str
          else
            provided[1] = flags[provided[1]]
            provided[0...2].each { |provided_piece| provides_str += "#{provided_piece} " }
            provided[2...-1].each { |provided_piece| provides_str += "#{provided_piece}." }
            results << provides_str[0...-1]
          end
        end
        results.uniq
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

      def update_model(model)
        custom_json = {}
        custom_json['modular'] = backend_data['is_modular']
        custom_json['pulp_id'] = backend_data['pulp_href']
        (PULP_INDEXED_FIELDS - ['is_modular', 'pulp_href', 'rpm_sourcerpm', 'pkgId', 'location_href']).
          each { |field| custom_json[field] = backend_data[field] }
        custom_json['release_sortable'] = Util::Package.sortable_version(backend_data['release'])
        custom_json['version_sortable'] = Util::Package.sortable_version(backend_data['version'])
        custom_json['filename'] = backend_data['location_href']
        custom_json['checksum'] = backend_data['pkgId']
        custom_json['sourcerpm'] = backend_data['rpm_sourcerpm']
        model.assign_attributes(custom_json)
        model.nvra = model.build_nvra
        model.save!
      end
    end
  end
end
