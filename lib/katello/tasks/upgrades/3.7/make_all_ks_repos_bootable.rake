namespace :katello do
  namespace :upgrades do
    namespace '3.7' do
      task :make_all_ks_repos_bootable => ["environment"] do
        User.current = User.anonymous_api_admin
        puts _("Ensuring all Kickstart Repos are bootable")
        Katello::Repository.import_distributions
      end
    end
  end
end
