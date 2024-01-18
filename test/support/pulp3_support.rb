module Katello
  module Pulp3Support
    extend ActiveSupport::Concern

    included do
      include VCR::TestCase
    end

    @repo_url = "file:///var/lib/pulp/sync_imports/test_repos/zoo"
    @repo = nil

    def orphan_cleanup
      Setting[:orphan_protection_time] = 0
      ForemanTasks.sync_task(::Actions::Pulp3::OrphanCleanup::RemoveOrphans, ::SmartProxy.pulp_primary)
    end

    def ensure_creatable(repo, smart_proxy)
      cert_path = "#{Katello::Engine.root}/test/fixtures/certs/content_guard.crt"
      cert = File.read(cert_path)
      Cert::Certs.stubs(:candlepin_client_ca_cert).returns(cert)
      Katello::Pulp3::ContentGuard.import(smart_proxy, true) unless repo.unprotected
      service = repo.backend_service(smart_proxy)
      service.class.any_instance.stubs(:generate_backend_object_name).returns(repo.pulp_id)

      tasks = []
      if (repo = service.list(name: service.generate_backend_object_name).first)
        tasks << service.api.repositories_api.delete(repo.pulp_href) rescue service.api.api_exception_class
      end

      if (remote = service.api.remotes_list(name: service.generate_backend_object_name).first)
        tasks << service.delete_remote(href: remote.pulp_href)
      end

      tasks.compact.each { |task| wait_on_task(smart_proxy, task) }
      tasks = []

      #delete distribution by name, since its not random due to vcr
      if (dist = service.lookup_distributions(name: service.generate_backend_object_name).first)
        tasks << service.api.delete_distribution(dist.pulp_href)
      end

      tasks << service.delete_distributions_by_path
      tasks.compact.each { |task| wait_on_task(smart_proxy, task) }
    end

    def wait_on_task(smart_proxy, tasks)
      tasks = tasks.as_json
      tasks = [tasks] unless tasks.is_a?(Array)
      tasks.each do |task|
        pulp_task = Katello::Pulp3::Task.new(smart_proxy, 'task' => task['pulp_href'] || task['task'])
        task_group_href = pulp_task.task_group_href

        if task_group_href
          task_group = Katello::Pulp3::TaskGroup.new_from_href(smart_proxy, task_group_href)
          is_done = pulp_task.done? && task_group.done?
        else
          is_done = pulp_task.done?
        end

        if is_done
          return task
        else
          sleep(0.1)
          wait_on_task(smart_proxy, task)
        end
      end
    end

    def tasks_api(smart_proxy)
      Katello::Pulp3::Api::Core.new(smart_proxy).tasks_api
    end

    def create_repo(repo, smart_proxy)
      ensure_creatable(repo, smart_proxy)
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Create, repo, smart_proxy)
      repo.reload
    end

    def create_and_sync(repo, smart_proxy)
      repo = create_repo(repo, smart_proxy)
      ForemanTasks.sync_task(
          ::Actions::Katello::Repository::MetadataGenerate, repo)

      repository_reference = Katello::Pulp3::RepositoryReference.find_by(
          :root_repository_id => repo.root.id,
          :content_view_id => repo.content_view.id)

      assert repository_reference
      refute_empty repository_reference.repository_href
      refute_empty Katello::Pulp3::DistributionReference.where(repository_id: repo.id)
      sync_args = {:smart_proxy_id => smart_proxy.id, :repo_id => repo.id}
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, repo, smart_proxy, **sync_args)
      repo
    end
  end
end
