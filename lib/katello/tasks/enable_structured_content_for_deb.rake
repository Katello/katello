namespace :katello do
  desc "Enable or disable the use of structured content for APT clients."
  task :enable_structured_content_for_deb, ['deb_use_structured_content'] => ['environment', 'dynflow:client', 'check_ping'] do |_t, args|
    unless ['true', 'false'].include?(args[:deb_use_structured_content])
      puts 'You must specify if structured content should be enabled or disabled, your options are:'
      puts '  foreman-rake katello:enable_structured_content_for_deb[true]'
      puts '  foreman-rake katello:enable_structured_content_for_deb[false]'
      puts "Note that use of structured content is currently set to '#{Setting['deb_use_structured_content']}'!"
      puts 'Note that after enabling structured content, you may need to resync your proxies!'
      exit 1
    end

    User.current = User.anonymous_api_admin
    deb_use_structured_content = ActiveModel::Type::Boolean.new.cast(args[:deb_use_structured_content])

    # Force deb_use_simple_publish to true, since we are not yet ready to drop simple publishing!
    Setting['deb_use_simple_publish'] = true

    # Update deb_use_structured_content and deb_sue_structured_proxy_sync to the value requested by the user:
    Setting['deb_use_structured_content'] = deb_use_structured_content
    Setting['deb_use_structured_proxy_sync'] = deb_use_structured_content

    # Ignore repositories where url is not set, since those are presumably empty or used for uploads!
    roots = Katello::RootRepository.deb_type.where.not(url: nil)
    roots.each do |root|
      # Note that we are assuming root.deb_releases must necessarily be set already if url is also set.
      components = root.deb_components
      if components.blank? && deb_use_structured_content
        repo = root.library_instance
        repo_backend_service = repo.backend_service(SmartProxy.pulp_primary)
        pulp_components = repo_backend_service.api.content_release_components_api.list(repository_version: repo.version_href)
        components = pulp_components.results.map(&:component).join(' ')
      end
      # We call a repository update action on every deb type root repository with an upstream url:
      ForemanTasks.sync_task(::Actions::Katello::Repository::Update, root, deb_components: components)
    end
  end
end
