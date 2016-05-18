namespace :katello do
  namespace :upgrades do
    namespace '2.4' do
      task :import_distributions => ["environment"] do
        User.current = User.anonymous_api_admin
        puts _("Importing distribution data into repositories")
        Katello::Repository.import_distributions
      end
    end
  end
end
