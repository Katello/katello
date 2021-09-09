module Katello
  module Pulp3
    class ModuleStream < PulpContentUnit
      include LazyAccessor

      def self.content_api
        PulpRpmClient::ContentModulemdsApi.new(Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::Yum.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.build_stream_rpms(katello_id, package_hrefs)
        package_ids = Katello::Rpm.where(:pulp_id => package_hrefs).pluck(:id)
        rpms = package_ids.map do |package_id|
          {
            module_stream_id: katello_id,
            rpm_id: package_id
          }
        end
        add_timestamps(rpms)
      end

      def self.build_artifacts(katello_id, artifacts_json)
        return [] if artifacts_json.nil?
        artifacts = artifacts_json.map do |name|
          {name: name,
           module_stream_id: katello_id}
        end
        add_timestamps(artifacts)
      end

      def self.build_profiles(katello_id, profiles_json)
        return [] if profiles_json.nil?
        profiles = profiles_json.map do |profile, _rpms|
          {
            module_stream_id: katello_id,
            name: profile
          }
        end
        add_timestamps(profiles)
      end

      def self.build_profile_rpms(katello_id, profiles_json)
        return [] if profiles_json.nil?
        profile_rpms = profiles_json.map do |profile, rpms|
          profile_id = Katello::ModuleProfile.find_by(module_stream_id: katello_id, name: profile).id
          rpms.map do |rpm|
            {
              module_profile_id: profile_id,
              name: rpm
            }
          end
        end
        add_timestamps(profile_rpms.flatten)
      end

      def self.generate_model_row(unit)
        shared_attributes = unit.keys & Katello::ModuleStream.column_names
        to_return = unit.select { |key, _v| shared_attributes.include?(key) }
        to_return['pulp_id'] = unit['pulp_href']
        to_return[:created_at] = DateTime.now
        to_return[:updated_at] = DateTime.now
        to_return
      end

      def self.add_timestamps(rows)
        rows.each do |row|
          row[:created_at] = DateTime.now
          row[:updated_at] = DateTime.now
        end
        rows
      end

      def self.insert_child_associations(units, pulp_id_to_id)
        artifacts = []
        profiles = []
        stream_rpms = []
        units.each do |unit|
          katello_id = pulp_id_to_id[unit[unit_identifier]]
          artifacts += build_artifacts(katello_id, unit['artifacts'])
          profiles += build_profiles(katello_id, unit['profiles'])
          stream_rpms += build_stream_rpms(katello_id, unit['packages'])
        end

        Katello::ModuleStreamArtifact.insert_all(artifacts, unique_by: [:module_stream_id, :name]) if artifacts.any?
        Katello::ModuleProfile.insert_all(profiles, unique_by: [:module_stream_id, :name]) if profiles.any?
        Katello::ModuleStreamRpm.insert_all(stream_rpms, unique_by: [:module_stream_id, :rpm_id]) if stream_rpms.any?

        #have to import profile_rpms after profiles
        profile_rpms = []
        units.each do |unit|
          katello_id = pulp_id_to_id[unit[unit_identifier]]
          profile_rpms += build_profile_rpms(katello_id, unit['profiles'])
        end
        Katello::ModuleProfileRpm.insert_all(profile_rpms, unique_by: [:module_profile_id, :name]) if profile_rpms.any?
      end
    end
  end
end
