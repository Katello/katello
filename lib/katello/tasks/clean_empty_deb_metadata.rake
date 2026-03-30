namespace :katello do
  desc <<-DESCRIPTION
  Removes obsolete empty deb metadata content from deb type library instance repositories.
  Options:
    REPO_ID: Must be set to a Katello repository ID to run the cleanup for just that repository.
             Can also be set to 'all_deb_library_instances', but this could take some time to finish.
  DESCRIPTION
  task :clean_empty_deb_metadata => ['environment', 'dynflow:client', 'check_ping'] do
    affected_repositories_counter = 0
    user_param = ENV['REPO_ID']
    if user_param.blank?
      puts 'Hint: The REPO_ID env var must be set to a Katello repository ID, or else to "all_deb_library_instances"!'
      fail 'REPO_ID is not set! Please re-run this rake task with a suitable value for REPO_ID!'
    elsif user_param == 'all_deb_library_instances'
      puts "Checking all deb type library instance repositories for obsolete empty metadata content."
      repositories_to_check = ::Katello::Repository.deb_type.library
    else
      single_repository = ::Katello::Repository.find(user_param)
      fail "Repository with REPO_ID=#{user_param} is not a deb type repository!" unless single_repository.deb?
      fail "Repository with REPO_ID=#{user_param} is not a library instance repository!" unless single_repository.library_instance?
      puts "Checking the deb type repository '#{single_repository.name}' with id='#{user_param}' for obsolete empty metadata content."
      repositories_to_check = [single_repository]
    end

    repositories_to_check.each do |repository|
      backend_service = repository.backend_service(SmartProxy.pulp_primary)
      version_href = repository.version_href
      query_opts = {
        :repository_version => version_href,
        :distribution => 'katello',
        :component => 'empty',
      }
      empty_component_query = backend_service.api.content_release_components_api.list(query_opts)
      next unless empty_component_query.count == 1

      affected_repositories_counter += 1
      component_href = empty_component_query.results[0].pulp_href
      repository_href = backend_service.repository_reference.repository_href
      task_href = backend_service.api.repositories_api.modify(repository_href, remove_content_units: [component_href], base_version: version_href).task

      pulp_task = Katello::Pulp3::Task.new(SmartProxy.pulp_primary, 'task' => task_href)
      start = Time.now
      loop do
        pulp_task.poll
        fail pulp_task.error if pulp_task.error
        break if pulp_task.done?
        fail 'Timed out' if (Time.now - start) > 600
        sleep 1
      end
      new_version_href = ::Katello::Pulp3::Task.version_href(pulp_task)
      fail "Pulp task '#{task_href}' has completed, but we could not extract a new version_href!" if new_version_href.nil?
      repository.version_href = new_version_href
      repository.save!

      ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repository)

      runner = Class.new do
        include ::Actions::Helpers::RollingCVRepos
      end
      runner.new.update_rolling_content_views_async(repository, true)
    end

    case affected_repositories_counter
    when 0
      puts "Found no repositories with obsolete empty metadata content."
    when 1
      puts "Removed obsolete empty metadata content from 1 repository."
    else
      puts "Removed obsolete empty metadata content from #{affected_repositories_counter} repositories."
    end
  end
end
