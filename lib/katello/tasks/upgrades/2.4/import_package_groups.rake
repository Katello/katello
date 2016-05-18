namespace :katello do
  namespace :upgrades do
    namespace '2.4' do
      task :import_package_groups => ["environment"] do
        User.current = User.anonymous_api_admin
        puts _("Importing Package Groups")
        Katello::PackageGroup.import_all
      end
    end
  end
end
