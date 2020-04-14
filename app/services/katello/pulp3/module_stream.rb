module Katello
  module Pulp3
    class ModuleStream < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpRpmClient::ContentModulemdsApi.new(Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_master!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def create_stream_rpms(model, packages)
        packages_found = Katello::Rpm.where(:pulp_id => packages)
        existing_rpms = model.rpms
        new_packages = packages_found - existing_rpms
        packages_to_delete = existing_rpms - packages_found
        model.rpms.delete(packages_to_delete)
        model.rpms << new_packages
      end

      def create_stream_artifacts(model, artifacts_json)
        artifacts_json.each do |name|
          Katello::Util::Support.active_record_retry do
            model.artifacts.where(name: name).first_or_create!
          end
        end
      end

      def create_profiles(model, profiles_json)
        profiles_json.each do |profile, rpms|
          Katello::Util::Support.active_record_retry do
            profile = model.profiles.where(name: profile).first_or_create!
          end
          rpms.each do |rpm|
            Katello::Util::Support.active_record_retry do
              profile.rpms.where(name: rpm).first_or_create!
            end
          end
        end
      end

      def update_model(model)
        shared_attributes = backend_data.keys & model.class.column_names
        shared_json = backend_data.select { |key, _v| shared_attributes.include?(key) }
        model.update!(shared_json)

        create_stream_artifacts(model, backend_data['artifacts']) if backend_data.key?('artifacts')
        create_profiles(model, backend_data['profiles']) if backend_data.key?('profiles')
        create_stream_rpms(model, backend_data['packages']) if backend_data.key?('packages')
      end
    end
  end
end
