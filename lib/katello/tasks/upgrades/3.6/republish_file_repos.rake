namespace :katello do
  namespace :upgrades do
    namespace '3.6' do
      desc "Republish FILE repos with relative paths including organization name"
      task :republish_file_repos => %w(environment check_ping) do
        User.current = User.anonymous_admin

        Katello::Repository.where(:content_type => Katello::Repository::FILE_TYPE).each do |repo|
          puts "Republishing file repo #{repo.name} (#{repo.id})..."
          ForemanTasks.sync_task(::Actions::Pulp::Repository::Refresh, repo)
          ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repo)
        end
      end
    end
  end
end
