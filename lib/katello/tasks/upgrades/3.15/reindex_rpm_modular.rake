namespace :katello do
  namespace :upgrades do
    namespace '3.15' do
      desc "Reindex the is_modular attribute of an rpm"
      task :reindex_rpm_modular, [:input_file] => ["environment"] do
        User.current = User.anonymous_api_admin
        criteria = { :fields => [],
                     :limit => SETTINGS[:katello][:pulp][:bulk_load_size],
                     :skip => 0,
                     :filters => {'is_modular' => {'$eq' => true}}
                   }
        content_type = Katello.pulp_server.extensions.rpm.content_type
        batch = ::Katello::Pulp::PulpContentUnit.pulp_units_batch(criteria, criteria[:limit]) do
          Katello.pulp_server.resources.unit.search(content_type, criteria)
        end
        pulp_modular_ids = batch.map { |response| response.pluck("_id") }.flatten
        db_modular_ids = ::Katello::Rpm.modular.pluck(:pulp_id)
        ::Katello::Rpm.where(pulp_id: db_modular_ids - pulp_modular_ids).update_all(modular: false)
        ::Katello::Rpm.where(pulp_id: pulp_modular_ids - db_modular_ids).update_all(modular: true)
      end
    end
  end
end
