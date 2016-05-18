namespace :katello do
  namespace :upgrades do
    namespace '2.4' do
      task :import_puppet_modules => ["environment"] do
        User.current = User.anonymous_api_admin
        puts _("Importing Puppet Modules")
        Katello::PuppetModule.import_all
      end
    end
  end
end
