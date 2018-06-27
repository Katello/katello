namespace :katello do
  namespace :upgrades do
    namespace '3.7' do
      task :import_pools => ["environment"] do
        User.current = User.anonymous_api_admin

        puts _("Importing Pools")
        Katello::Pool.import_all
      end
    end
  end
end
