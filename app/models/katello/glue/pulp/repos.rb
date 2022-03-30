require 'openssl'

module Katello
  module Glue::Pulp::Repos
    def self.included(base)
      base.send :include, InstanceMethods
    end

    def self.repo_path_from_content_path(environment, content_path)
      path = content_path.sub(%r|^/|, '')
      path_prefix = [environment.organization.label, environment.label].join('/')
      "#{path_prefix}/#{path}"
    end

    module InstanceMethods
      def distributions(env)
        to_ret = []
        self.repos(env).each do |repo|
          distros = repo.distributions
          to_ret += distros unless distros.empty?
        end
        to_ret
      end

      def promoted_to?(target_env)
        target_env.products.include? self
      end

      def sync
        Rails.logger.debug "Syncing product #{self.label}"
        repos = self.repos(library).collect do |r|
          r.sync
        end
        repos.flatten
      end

      def synced?
        !last_repo_sync_task.nil?
      end

      # Get the most relevant status for all the repos in this Product
      def sync_status
        all_repos = repos(self.library, nil, false)
        task = last_repo_sync_task
        last_synced_repo = task ? all_repos.find { |repo| task.links.where(:resource_type => ::Katello::Repository.name).pluck(:resource_id).map(&:to_s).include?(repo.id.to_s) } : nil
        ::Katello::SyncStatusPresenter.new(last_synced_repo, task).sync_progress
      end

      def sync_summary
        summary = {}
        last_repo_sync_task_by_repoid.values.each do |task|
          summary[task.result] ||= 0
          summary[task.result] += 1
        end
        summary
      end

      def last_sync_audit
        Audited::Audit.where(:auditable_id => self.repositories, :auditable_type => Katello::Repository.name).order(:created_at).last
      end

      def last_sync
        last_repo_sync_task&.started_at&.to_s || last_sync_audit&.created_at&.to_s
      end

      def last_repo_sync_task
        @last_sync_task ||= last_repo_sync_tasks.first
      end

      def last_repo_sync_tasks
        all_repos = repos(self.library, nil, false)
        ForemanTasks::Task::DynflowTask
          .select("#{ForemanTasks::Task::DynflowTask.table_name}.*")
          .where(:label => ::Actions::Katello::Repository::Sync.name)
          .joins(:locks).where("foreman_tasks_locks.resource_id in (?) and foreman_tasks_locks.resource_type = ?", all_repos.pluck(:id), ::Katello::Repository.name)
          .order("started_at desc")
      end

      def last_repo_sync_task_group
        if last_repo_sync_task
          started_after = last_repo_sync_task.started_at - 30.seconds
          last_repo_sync_tasks.where("#{ForemanTasks::Task::DynflowTask.table_name}.started_at > '%s'", started_after.utc).uniq
        else
          []
        end
      end

      def last_repo_sync_task_by_repoid
        all_repos = repos(self.library, nil, false)
        base_combined_table = ForemanTasks::Task::DynflowTask
          .where(:label => ::Actions::Katello::Repository::Sync.name)
          .joins(:locks)
          .where("foreman_tasks_locks.resource_id in (?) and foreman_tasks_locks.resource_type = ?", all_repos.pluck(:id), ::Katello::Repository.name)

        max_per_repoid = ForemanTasks::Task::DynflowTask
          .joins(:locks)
          .select("#{ForemanTasks::Task::DynflowTask.table_name}.*, inner_select.resource_id")
          .joins(
            "INNER JOIN (#{base_combined_table
              .select("MAX(foreman_tasks_tasks.started_at) AS started_at", "foreman_tasks_locks.resource_id AS resource_id")
              .group("foreman_tasks_locks.resource_id")
              .to_sql}) inner_select
            ON inner_select.started_at = #{ForemanTasks::Task::DynflowTask.table_name}.started_at
            AND inner_select.resource_id = locks_foreman_tasks_tasks.resource_id")
          .distinct

        max_per_repoid.index_by { |x| [x.resource_id, x] }
      end

      def sync_state_aggregated
        presented = last_repo_sync_task_by_repoid.transform_values { |v| ::Katello::SyncStatusPresenter.new(Katello::Repository.find(v.input["repository"]["id"]), v) }
        worst = nil
        scale = [
          :never_synced,
          :stopped,
          :canceled,
          :error,
          :paused,
          :running
        ]

        presented.each do |_repoid, task|
          worst = task if worst.nil? || worst.sync_progress[:state].nil? || scale.index(worst.sync_progress[:raw_state].to_sym) < scale.index(task.sync_progress[:raw_state].to_sym)
        end
        worst&.sync_progress&.fetch(:state, nil)
      end

      def sync_state
        self.sync_status[:state]
      end

      def sync_size
        self.repos(library).inject(0) do |sum, v|
          sum + v.sync_status.progress.total_size
        end
      end

      def repo_url(content_url)
        if self.provider.provider_type == Provider::CUSTOM
          content_url.dup
        else
          path = content_url.sub(%r{^/}, '')
          repo_url = self.provider.repository_url&.sub(%r{/$}, '')
          "#{repo_url}/#{path}"
        end
      end

      def add_repo(repo_param)
        repo_param[:unprotected] = repo_param[:unprotected].nil? ? false : repo_param[:unprotected]

        if repo_param[:download_policy].blank? && repo_param[:content_type].in?([Repository::YUM_TYPE, Repository::DEB_TYPE])
          repo_param[:download_policy] = Setting[:default_download_policy]
        end

        repo_param[:mirroring_policy] = Katello::RootRepository::MIRRORING_POLICY_ADDITIVE if repo_param[:mirroring_policy].blank?

        RootRepository.new(repo_param.merge(:product_id => self.id))
      end
    end
  end
end
