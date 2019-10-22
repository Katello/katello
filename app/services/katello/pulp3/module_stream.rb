module Katello
  module Pulp3
    class ModuleStream < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpRpmClient::ContentModulemdApi.new(Katello::Pulp3::Repository::Yum.api_client(SmartProxy.pulp_master!))
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::ModuleStream.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
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
        model.update_attributes!(shared_json)

        create_stream_artifacts(model, JSON.parse(backend_data['artifacts'])) if backend_data.key?('artifacts')
        create_profiles(model, JSON.parse(backend_data['profiles'])) if backend_data.key?('profiles')
      end
    end
  end
end
