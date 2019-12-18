module Katello
  module Pulp3
    class Srpm < PulpContentUnit
      include LazyAccessor

      PULP_INDEXED_FIELDS = %w(pulp_href name version release arch epoch summary location_href pkgId).freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      lazy_accessor :description, :license, :buildhost, :vendor, :relativepath, :children, :checksumtype,
                    :changelog, :group, :size, :url, :build_time, :group,
                    :initializer => :pulp_facts

      def self.content_api
        PulpRpmClient::ContentPackagesApi.new(Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_master!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
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
        custom_json['pulp_id'] = backend_data['pulp_href']
        (PULP_INDEXED_FIELDS - ['pulp_href', 'pkgId', 'location_href']).
          each { |field| custom_json[field] = backend_data[field] }
        custom_json['release_sortable'] = Util::Package.sortable_version(backend_data['release'])
        custom_json['version_sortable'] = Util::Package.sortable_version(backend_data['version'])
        custom_json['nvra'] = model.build_nvra
        custom_json['filename'] = backend_data['location_href']
        custom_json['checksum'] = backend_data['pkgId']
        model.update_attributes!(custom_json)
      end
    end
  end
end
