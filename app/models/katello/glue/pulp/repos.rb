require 'openssl'

module Katello
  module Glue::Pulp::Repos
    def self.included(base)
      base.send :include, InstanceMethods
    end

    def self.repo_path_from_content_path(environment, content_path)
      content_path = content_path.sub(/^\//, "")
      path_prefix = [environment.organization.label, environment.label].join("/")
      "#{path_prefix}/#{content_path}"
    end

    # repo path for custom product repos (RH repo paths are derived from
    # content url)
    def self.custom_repo_path(environment, product, repo_label)
      if [environment, product, repo_label].any?(&:nil?)
        return nil # can't generate valid path
      end
      prefix = [environment.organization.label, environment.label].map { |x| x.gsub(/[^-\w]/, "_") }.join("/")
      prefix + custom_content_path(product, repo_label)
    end

    def self.custom_docker_repo_path(environment, product, repo_label)
      if [environment, product, repo_label].any?(&:nil?)
        return nil # can't generate valid path
      end
      parts = [environment.organization.label, product.label, repo_label]
      parts.map { |x| x.gsub(/[^-\w]/, "_") }.join("-").downcase
    end

    def self.custom_content_path(product, repo_label)
      parts = []
      # We generate repo path only for custom product content. We add this
      # constant string to avoid collisions with RH content. RH content url
      # begins usually with something like "/content/dist/rhel/...".
      # There we prefix custom content/repo url with "/custom/..."
      parts << "custom"
      parts += [product.label, repo_label]
      "/" + parts.map { |x| x.gsub(/[^-\w]/, "_") }.join("/")
    end

    def self.prepopulate!(products, environment, repos = [], content_view = nil)
      if content_view.nil?
        if environment.library?
          content_view = environment.default_content_view
        else
          fail "No content view specified for a Non library environment #{environment.inspect}"
        end
      end

      items = Katello.pulp_server.extensions.repository.search_by_repository_ids(Repository.in_environment(environment).pluck(:pulp_id))
      full_repos = {}
      items.each { |item| full_repos[item["id"]] = item }

      products.each do |prod|
        prod.repos(environment, content_view).each do |repo|
          repo.populate_from(full_repos)
        end
      end
      repos.each { |repo| repo.populate_from(full_repos) }
    end

    module InstanceMethods
      def empty?
        return self.repos(library).empty?
      end

      def promote(from_env, to_env)
        @orchestration_for = :promote

        async_tasks = promote_repos repos(from_env), from_env, to_env
        unless to_env.products.include? self
          self.environments << to_env
        end

        save!
        async_tasks
      end

      def find_packages_by_name(env, name)
        packages = self.repos(env).collect do |repo|
          repo.find_packages_by_name(name).collect do |p|
            p[:repo_id] = repo.id
            p
          end
        end
        packages.flatten(1)
      end

      def find_packages_by_nvre(env, name, version, release, epoch)
        packages = self.repos(env).collect do |repo|
          repo.find_packages_by_nvre(name, version, release, epoch).collect do |p|
            p[:repo_id] = repo.id
            p
          end
        end
        packages.flatten(1)
      end

      def distributions(env)
        to_ret = []
        self.repos(env).each do |repo|
          distros = repo.distributions
          to_ret += distros unless distros.empty?
        end
        to_ret
      end

      def get_distribution(env, id)
        distribution = self.repos(env).map do |repo|
          repo.distributions.find_all { |d| d.id == id }
        end
        distribution.flatten(1)
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
        last_synced_repo = task ? all_repos.find { |repo| task.locks.where(:resource_type => ::Katello::Repository.name).pluck(:resource_id).map(&:to_s).include?(repo.id.to_s) } : nil
        ::Katello::SyncStatusPresenter.new(last_synced_repo, task).sync_progress
      end

      def sync_summary
        summary = {}
        last_repo_sync_task_group.each do |task|
          summary[task.result] ||= 0
          summary[task.result] += 1
        end
        summary
      end

      def last_sync
        task = last_repo_sync_task
        task.nil? ? nil : task.started_at.to_s
      end

      def last_repo_sync_task
        @last_sync_task ||= last_repo_sync_tasks.first
      end

      def last_repo_sync_tasks
        all_repos = repos(self.library, nil, false)
        ForemanTasks::Task::DynflowTask
          .select("#{ForemanTasks::Task::DynflowTask.table_name}.*")
          .where(:label => [::Actions::Katello::Repository::Sync.name, ::Actions::Katello::Repository::ScheduledSync.name])
          .joins(:locks).where("foreman_tasks_locks.resource_id in (?) and foreman_tasks_locks.resource_type = ?", all_repos.pluck(:id), ::Katello::Repository.name)
          .order("started_at desc")
      end

      def last_repo_sync_task_group
        if last_repo_sync_task
          started_after = last_repo_sync_task.started_at - 30.seconds
          last_repo_sync_tasks.where("#{ForemanTasks::Task::DynflowTask.table_name}.started_at > '%s'", started_after).uniq
        else
          []
        end
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
          self.provider.repository_url + content_url
        end
      end

      def add_repo(repo_param)
        repo_param[:unprotected] = repo_param[:unprotected].nil? ? false : repo_param[:unprotected]

        if repo_param[:download_policy].blank? && repo_param[:content_type] == Repository::YUM_TYPE
          repo_param[:download_policy] = Setting[:default_download_policy]
        end

        rel_path = if repo_param[:content_type] == 'docker'
                     Glue::Pulp::Repos.custom_docker_repo_path(self.library, self, repo_param[:label])
                   else
                     Glue::Pulp::Repos.custom_repo_path(self.library, self, repo_param[:label])
                   end
        Repository.new(:environment => self.organization.library,
                       :product => self,
                       :relative_path => rel_path,
                       :arch => repo_param[:arch],
                       :name => repo_param[:name],
                       :label => repo_param[:label],
                       :url => repo_param[:url],
                       :gpg_key => repo_param[:gpg_key],
                       :ssl_ca_cert => repo_param[:ssl_ca_cert],
                       :ssl_client_cert => repo_param[:ssl_client_cert],
                       :ssl_client_key => repo_param[:ssl_client_key],
                       :unprotected => repo_param[:unprotected],
                       :content_type => repo_param[:content_type],
                       :checksum_type => repo_param[:checksum_type],
                       :download_policy => repo_param[:download_policy],
                       :content_view_version => self.organization.library.default_content_view_version)
      end

      def setup_sync_schedule
        schedule = (self.sync_plan && self.sync_plan.schedule_format) || nil
        self.repos(self.library).each do |repo|
          repo.sync_schedule(schedule)
        end
      end

      def custom_repos_create_orchestration
        pre_queue.create(:name => "create pulp repositories for product: #{self.label}", :priority => 1, :action => [self, :set_repos])
      end

      protected

      def promote_repos(repos, from_env, to_env)
        async_tasks = []
        repos.each do |repo|
          async_tasks << repo.promote(from_env, to_env)
        end
        async_tasks.flatten(1)
      end
    end
  end
end
