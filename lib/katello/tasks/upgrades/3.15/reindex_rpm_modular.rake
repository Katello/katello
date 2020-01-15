namespace :katello do
  namespace :upgrades do
    namespace '3.15' do
      desc "Reindex the is_modular attribute of an rpm"
      def update_modular(pulp_response)
        modular = []
        non_modular = []
        pulp_response.each do |rpm|
          if rpm["is_modular"]
            modular << rpm["_id"]
          else
            non_modular << rpm["_id"] unless rpm["is_modular"]
          end
        end
        ::Katello::Rpm.where(pulp_id: modular).update_all(modular: true)
        ::Katello::Rpm.where(pulp_id: non_modular).update_all(modular: false)
      end

      task :reindex_rpm_modular, [:input_file] => ["environment"] do
        User.current = User.anonymous_api_admin
        criteria = { :fields => ["is_modular"],
                     :limit => SETTINGS[:katello][:pulp][:bulk_load_size],
                     :skip => 0
                   }
        content_type = Katello.pulp_server.extensions.rpm.content_type
        batch = ::Katello::Pulp::PulpContentUnit.pulp_units_batch(criteria, criteria[:limit]) do
          Katello.pulp_server.resources.unit.search(content_type, criteria)
        end

        batch.each do |pulp_response|
          update_modular(pulp_response)
        end
      end
    end
  end
end
