namespace :katello do
  namespace :upgrades do
    namespace '3.0' do
      task :delete_docker_v1_content => ["environment"] do
        print _("Deleting repositories that only contain Docker v1 content....")
        User.current = User.anonymous_admin
        docker_repositories = Katello::Repository.where(:content_type => Katello::Repository::DOCKER_TYPE, :library_instance_id => nil)

        v1_repos = docker_repositories.select do |repo|
          docker_images_count = Katello.pulp_server.extensions.repository.docker_images(repo.pulp_id).size
          repo_units_count = Katello.pulp_server.extensions.repository.unit_search(repo.pulp_id).size
          docker_images_count > 0 && docker_images_count == repo_units_count
        end

        v1_repos.each do |v1_repo|
          v1_repo.clones.each do |clone|
            ForemanTasks.sync_task(::Actions::Katello::Repository::Destroy, clone, :planned_destroy => true)
          end
          ForemanTasks.sync_task(::Actions::Katello::Repository::Destroy, v1_repo, :planned_destroy => true)
        end

        puts _("Done")
        Rake::Task["katello:delete_orphaned_content"].invoke
      end
    end
  end
end
