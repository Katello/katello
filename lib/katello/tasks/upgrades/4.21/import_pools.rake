namespace :katello do
  namespace :upgrades do
    namespace '4.21' do
      desc "Import Katello Pools to allow additional cached attributes"
      task :import_pools => ['environment', 'dynflow:client', "check_ping"] do
        Katello::Pool.import_all
      end
    end
  end
end
