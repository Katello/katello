module Katello
  module Pulp3
    class PackageGroup < PulpContentUnit
      include LazyAccessor

      lazy_accessor :optional_package_names, :mandatory_package_names,
                    :conditional_package_names, :default_package_names, :_id,
                    :repository_memberships,
                    :initializer => :backend_data

      def _id
        backend_data['pulp_href']
      end

      # Package type is now an integer:
      # 0. default
      # 1. optional
      # 2. conditional
      # 3. mandatory
      # 4. unknown
      # https://github.com/rpm-software-management/libcomps/blob/01a4759894cccff64d2561614a58281adf5ce859/libcomps/src/comps_docpackage.h#L36
      def default_package_names
        package_names_of_type(0)
      end

      def optional_package_names
        package_names_of_type(1)
      end

      def conditional_package_names
        package_names_of_type(2)
      end

      def mandatory_package_names
        package_names_of_type(3)
      end

      def unknown_package_names
        package_names_of_type(4)
      end

      def package_names_of_type(type)
        filtered_packages = backend_data['packages'].select { |package| package['type'] == type }
        filtered_packages.map { |package| package['name'] }
      end

      def self.content_api
        PulpRpmClient::ContentPackagegroupsApi.new(Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.generate_model_row(unit)
        custom_json = {}
        custom_json['pulp_id'] = unit['pulp_href']
        custom_json['name'] = unit['name']
        custom_json['description'] = unit['description']
        custom_json
      end
    end
  end
end
