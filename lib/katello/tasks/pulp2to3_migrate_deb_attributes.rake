namespace :katello do
  desc "Migrate deb content attributes to Pulp3"
  task :migrate_deb_content_attributes_to_pulp3 => ["environment", "check_ping"] do
    User.current = User.anonymous_api_admin
    repos = Katello::Repository.deb_type.where(library_instance_id: nil)

    repos.find_each.with_index do |repo, index|
      puts "Processing Repository #{index + 1}/#{repos.count}: #{repo.name} (#{repo.id})"
      begin
        ForemanTasks.sync_task(::Actions::Katello::Repository::Update, repo.root,
                               download_policy: 'immediate',
                               deb_architectures: repo.root.deb_architectures&.gsub(',', ' '),
                               deb_releases: repo.root.deb_releases&.gsub(',', ' '),
                               deb_components: repo.root.deb_components&.gsub(',', ' '))
      rescue => e
        puts "Failed to update repository #{repo.name} (#{repo.id}): #{e.message}"
      end
    end
  end
end
