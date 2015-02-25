#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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

      def package_groups(env, search_args = {})
        groups = []
        self.repos(env).each do |repo|
          groups << repo.package_groups(search_args)
        end
        groups.flatten(1)
      end

      def package_group_categories(env, search_args = {})
        categories = []
        self.repos(env).each do |repo|
          categories << repo.package_group_categories(search_args)
        end
        categories.flatten(1)
      end

      def package?(id)
        self.repos(env).each do |repo|
          return true if repo.package?(id)
        end
        false
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
          to_ret +=  distros unless distros.empty?
        end
        to_ret
      end

      def get_distribution(env, id)
        distribution = self.repos(env).map do |repo|
          repo.distributions.find_all { |d| d.id == id }
        end
        distribution.flatten(1)
      end

      def find_latest_packages_by_name(env, name)
        packs = self.repos(env).collect do |repo|
          repo.find_latest_packages_by_name(name).collect do |pack|
            pack[:repo_id] = repo.id
            pack
          end
        end
        packs.flatten!(1)

        Util::Package.find_latest_packages packs
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
        self.repos(library).any? { |r| r.synced? }
      end

      #get last sync status of all repositories in this product
      def latest_sync_statuses
        self.repos(library).collect do |r|
          r._get_most_recent_sync_status
        end
      end

      # Get the most relevant status for all the repos in this Product
      def sync_status
        return @status if @status

        statuses = repos(self.library, nil, false).map { |r| r.sync_status }
        return PulpSyncStatus.new(:state => PulpSyncStatus::Status::NOT_SYNCED) if statuses.empty?

        #if any of repos sync still running -> product sync running
        idx = statuses.index { |r| r.state.to_s == PulpSyncStatus::Status::RUNNING.to_s }
        return statuses[idx] unless idx.nil?

        #else if any of repos not synced -> product not synced
        idx = statuses.index { |r| r.state.to_s == PulpSyncStatus::Status::NOT_SYNCED.to_s }
        return statuses[idx] unless idx.nil?

        #else if any of repos sync cancelled -> product sync cancelled
        idx = statuses.index { |r| r.state.to_s == PulpSyncStatus::Status::CANCELED.to_s }
        return statuses[idx] unless idx.nil?

        #else if any of repos sync finished with error -> product sync finished with error
        idx = statuses.index { |r| r.state.to_s == PulpSyncStatus::Status::ERROR.to_s }
        return statuses[idx] unless idx.nil?

        #else -> all finished
        @status = statuses[0]
      end

      def sync_state
        self.sync_status.state
      end

      def sync_start
        start_times = []
        repos(library).each do |r|
          start = r.sync_start
          start_times << start unless start.nil?
        end
        start_times.sort!
        start_times.last
      end

      def sync_finish
        finish_times = []
        repos(library).each do |r|
          finish = r.sync_finish
          finish_times << finish unless finish.nil?
        end
        finish_times.sort!
        finish_times.last
      end

      def sync_size
        self.repos(library).inject(0) do |sum, v|
          sum + v.sync_status.progress.total_size
        end
      end

      def sync_summary
        summary = {}
        latest_repo_sync_tasks.each do |task|
          summary[task.result] ||= 0
          summary[task.result] += 1
        end
        summary
      end

      def last_sync
        task = last_repo_sync_task
        task.nil? ? nil : task.started_at.to_s
      end

      def latest_repo_sync_tasks
        repos(library).map { |repo| repo.latest_dynflow_sync }.compact
      end

      def last_repo_sync_task
        latest_repo_sync_tasks.sort_by(&:started_at).last
      end

      def cancel_sync
        Rails.logger.info "Canceling synchronization of product #{self.label}"
        repos(library).each do |r|
          r.cancel_sync
        end
      end

      def repo_id(content_name, env_label = nil)
        return if content_name.nil?
        return content_name if content_name.include?(self.organization.label) && content_name.include?(self.label.to_s)
        Repository.repo_id(self.label.to_s, content_name.to_s, env_label, self.organization.label, nil, nil)
      end

      def repo_url(content_url, repo_content_type = ::Katello::Repository::YUM_TYPE)
        if self.provider.provider_type == Provider::CUSTOM
          content_url.dup
        else
          rh_url = if repo_content_type == ::Katello::Repository::YUM_TYPE
                     self.provider.repository_url
                   else
                     self.provider.docker_registry_url
                   end
          rh_url + content_url
        end
      end

      def update_repositories
        repos = Repository.in_product(self).in_default_view
        upstream_ca = File.read(Resources::CDN::CdnResource.ca_file)
        repos.each do |repo|
          key = nil
          ca = nil
          cert = nil
          if repo.environment.library? && repo.content_view.default?
            key = self.key
            cert = self.certificate
            ca = upstream_ca
          end
          repo.refresh_pulp_repo(ca, cert, key)
        end
      end

      def add_repo(label, name, url, repo_type, unprotected = false, gpg = nil, checksum_type = nil)
        unprotected = unprotected.nil? ? false : unprotected
        rel_path = if repo_type == 'docker'
                     Glue::Pulp::Repos.custom_docker_repo_path(self.library, self, label)
                   else
                     Glue::Pulp::Repos.custom_repo_path(self.library, self, label)
                   end
        Repository.new(:environment => self.organization.library,
                       :product => self,
                       :pulp_id => repo_id(label),
                       :relative_path => rel_path,
                       :arch => arch,
                       :name => name,
                       :label => label,
                       :url => url,
                       :gpg_key => gpg,
                       :unprotected => unprotected,
                       :content_type => repo_type,
                       :checksum_type => checksum_type,
                       :content_view_version => self.organization.library.default_content_view_version)
      end

      def setup_sync_schedule
        schedule = (self.sync_plan && self.sync_plan.schedule_format) || nil
        self.repos(self.library).each do |repo|
          repo.sync_schedule(schedule)
        end
      end

      def custom_repos_create_orchestration
        pre_queue.create(:name => "create pulp repositories for product: #{self.label}",      :priority => 1, :action => [self, :set_repos])
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
