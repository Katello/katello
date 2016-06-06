namespace :katello do
  namespace :upgrades do
    namespace '3.0' do
      task :update_puppet_repository_distributors => ["environment"] do
        User.current = User.anonymous_api_admin
        puts _("Updating Puppet Repository Distributors")
        Katello::Repository.puppet_type.each do |repo|
          ForemanTasks.sync_task(::Actions::Pulp::Repository::Refresh, repo)
          ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repo)
        end

        puts _("Updating Content View Puppet Environment Distributors")
        Katello::ContentViewPuppetEnvironment.all.each do |repo|
          ForemanTasks.sync_task(::Actions::Pulp::Repository::Refresh, repo)
          ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repo)
        end
      end
    end
  end
end
