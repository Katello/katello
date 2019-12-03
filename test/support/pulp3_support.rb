module Katello
  module Pulp3Support
    extend ActiveSupport::Concern

    included do
      include VCR::TestCase
    end

    @repo_url = "file:///var/www/test_repos/zoo"
    @repo = nil

    def ensure_creatable(repo, smart_proxy)
      service = repo.backend_service(smart_proxy)
      service.class.any_instance.stubs(:generate_backend_object_name).returns(repo.pulp_id)

      tasks = []
      if (repo = service.list(name: service.generate_backend_object_name).first)
        tasks << service.delete(repo.pulp_href)
      end

      if (remote = service.api.remotes_list(name: service.generate_backend_object_name).first)
        tasks << service.delete_remote(remote.pulp_href)
      end

      #delete distribution by name, since its not random due to vcr
      if (dist = service.lookup_distributions(name: service.generate_backend_object_name).first)
        tasks << service.api.delete_distribution(dist.pulp_href)
      end

      tasks << service.delete_distributions_by_path
      tasks.compact.each { |task| wait_on_task(smart_proxy, task) }
    end

    def wait_on_task(smart_proxy, task)
      task = task.as_json
      task = tasks_api(smart_proxy).read(task['pulp_href'] || task['task']).as_json.with_indifferent_access
      if task[:finished_at] || Actions::Pulp3::AbstractAsyncTask::FINISHED_STATES.include?(task[:state])
        return task
      else
        sleep(0.1)
        wait_on_task(smart_proxy, task)
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
  end
end
