module Katello
  module Pulp
    class ModuleStream < PulpContentUnit
      include LazyAccessor

      CONTENT_TYPE = "modulemd".freeze

      def update_model(model)
        shared_attributes = backend_data.keys & model.class.column_names
        shared_json = backend_data.select { |key, _v| shared_attributes.include?(key) }
        model.update!(shared_json)

        create_stream_artifacts(model, backend_data['artifacts']) if backend_data.key?('artifacts')
        create_profiles(model, backend_data['profiles']) if backend_data.key?('profiles')
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
    end
  end
end
