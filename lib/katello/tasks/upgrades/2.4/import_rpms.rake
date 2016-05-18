namespace :katello do
  namespace :upgrades do
    namespace '2.4' do
      task :import_rpms => ["environment"] do
        User.current = User.anonymous_api_admin

        puts _("Importing Rpms")
        Katello::Rpm.import_all
      end
    end
  end
end
