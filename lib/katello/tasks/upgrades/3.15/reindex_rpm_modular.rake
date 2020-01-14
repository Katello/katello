namespace :katello do
  namespace :upgrades do
    namespace '3.15' do
      desc "Reindex the is_modular attribute of an rpm"
      task :reindex_rpm_modular, [:input_file] => ["environment"] do
        User.current = User.anonymous_api_admin
        rpms = Katello.pulp_server.resources.unit.search(Katello.pulp_server.extensions.rpm.content_type, :fields => ["is_modular"])
        modular = []
        non_modular = []
        rpms.each do |rpm|
          if rpm["is_modular"]
            modular << rpm["_id"]
          else
            non_modular << rpm["_id"] unless rpm["is_modular"]
          end
        end
        ::Katello::Rpm.where(pulp_id: modular).update_all(modular: true)
        ::Katello::Rpm.where(pulp_id: non_modular).update_all(modular: false)
      end
    end
  end
end
