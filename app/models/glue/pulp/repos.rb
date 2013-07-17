#
# Copyright 2013 Red Hat, Inc.
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

module Glue::Pulp::Repos

  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      before_save :save_repos_orchestration
      before_destroy :destroy_repos_orchestration
    end
  end

  def self.repo_path_from_content_path(environment, content_path)
    content_path = content_path.sub(/^\//, "")
    path_prefix = [environment.organization.label, environment.label].join("/")
    "#{path_prefix}/#{content_path}"
  end


  # repo path for custom product repos (RH repo paths are derived from
  # content url)
  def self.custom_repo_path(environment, product, repo_label)
    prefix = [environment.organization.label,environment.label].map{|x| x.gsub(/[^-\w]/,"_") }.join("/")
    prefix + custom_content_path(product, repo_label)
  end

  def self.custom_content_path(product, repo_label)
    parts = []
    # We generate repo path only for custom product content. We add this
    # constant string to avoid collisions with RH content. RH content url
    # begins usually with something like "/content/dist/rhel/...".
    # There we prefix custom content/repo url with "/custom/..."
    parts << "custom"
    parts += [product.label, repo_label]
    "/" + parts.map{|x| x.gsub(/[^-\w]/,"_") }.join("/")
  end

  def self.clone_repo_path_for_cp(repo)
    Repository.clone_repo_path(repo, nil, nil, true)
  end


  def self.prepopulate!(products, environment, repos = [])
    items = Runcible::Extensions::Repository.search_by_repository_ids(Repository.in_environment(environment).pluck(:pulp_id))
    full_repos = {}
    items.each { |item| full_repos[item["id"]] = item }

    products.each do |prod|
      prod.repos(environment, true).each do |repo|
        repo.populate_from(full_repos)
      end
    end
    repos.each { |repo| repo.populate_from(full_repos) }
  end

  module InstanceMethods

    def empty?
      return self.repos(library).empty?
    end

    def promote from_env, to_env
      @orchestration_for = :promote

      async_tasks = promote_repos repos(from_env), from_env, to_env
      if !to_env.products.include? self
        self.environments << to_env
      end

      save!
      async_tasks
    end

    def package_groups env, search_args = {}
      groups = []
      self.repos(env).each do |repo|
        groups << repo.package_groups(search_args)
      end
      groups.flatten(1)
    end

    def package_group_categories env, search_args = {}
      categories = []
      self.repos(env).each do |repo|
        categories << repo.package_group_categories(search_args)
      end
      categories.flatten(1)
    end

    def has_package? id
      self.repos(env).each do |repo|
        return true if repo.has_package? id
      end
      false
    end

    def find_packages_by_name env, name
      self.repos(env).collect do |repo|
        repo.find_packages_by_name(name).collect do |p|
          p[:repo_id] = repo.id
          p
        end
      end.flatten(1)
    end

    def find_packages_by_nvre env, name, version, release, epoch
      self.repos(env).collect do |repo|
        repo.find_packages_by_nvre(name, version, release, epoch).collect do |p|
          p[:repo_id] = repo.id
          p
        end
      end.flatten(1)
    end

    def distributions env
      to_ret = []
      self.repos(env).each{|repo|
        distros = repo.distributions
        to_ret = to_ret +  distros if !distros.empty?
      }
      to_ret
    end

    def get_distribution env, id
      self.repos(env).map do |repo|
        repo.distributions.find_all {|d| d.id == id }
      end.flatten(1)
    end

    def find_latest_packages_by_name env, name

      packs = self.repos(env).collect do |repo|
        repo.find_latest_packages_by_name(name).collect do |pack|
          pack[:repo_id] = repo.id
          pack
        end
      end.flatten(1)

      Util::Package.find_latest_packages packs
    end

    def has_erratum? env, id
      self.repos(env).each do |repo|
        return true if repo.has_erratum? id
      end
      false
    end

    def promoted_to? target_env
      target_env.products.include? self
    end

    def sync
      Rails.logger.debug "Syncing product #{self.label}"
      self.repos(library).collect do |r|
        r.sync
      end.flatten
    end

    def synced?
      self.repos(library).any? { |r| r.synced? }
    end

    #get last sync status of all repositories in this product
    def latest_sync_statuses
      self.repos(library).collect do |r|
        r._get_most_recent_sync_status()
      end
    end

    # Get the most relevant status for all the repos in this Product
    def sync_status
      return @status if @status

      statuses = repos(self.library).map {|r| r.sync_status()}
      return ::PulpSyncStatus.new(:state => ::PulpSyncStatus::Status::NOT_SYNCED) if statuses.empty?

      #if any of repos sync still running -> product sync running
      idx = statuses.index do |r| r.state.to_s == ::PulpSyncStatus::Status::RUNNING.to_s end
      return statuses[idx] if idx != nil

      #else if any of repos not synced -> product not synced
      idx = statuses.index do |r| r.state.to_s == ::PulpSyncStatus::Status::NOT_SYNCED.to_s end
      return statuses[idx] if idx != nil

      #else if any of repos sync cancelled -> product sync cancelled
      idx = statuses.index do |r| r.state.to_s == ::PulpSyncStatus::Status::CANCELED.to_s end
      return statuses[idx] if idx != nil

      #else if any of repos sync finished with error -> product sync finished with error
      idx = statuses.index do |r| r.state.to_s == ::PulpSyncStatus::Status::ERROR.to_s end
      return statuses[idx] if idx != nil

      #else -> all finished
      @status = statuses[0]
    end

    def sync_state
      self.sync_status().state
    end

    def sync_start
      start_times = Array.new
      for r in repos(library)
        start = r.sync_start
        start_times << start unless start.nil?
      end
      start_times.sort!
      start_times.last
    end

    def sync_finish
      finish_times = Array.new
      for r in repos(library)
        finish = r.sync_finish
        finish_times << finish unless finish.nil?
      end
      finish_times.sort!
      finish_times.last
    end

    def sync_size
      self.repos(library).inject(0) { |sum, v|
        sum + v.sync_status.progress.total_size
      }
    end

    def last_sync
      sync_times = Array.new
      for r in repos(library)
        sync = r.last_sync
        sync_times << sync unless sync.nil?
      end
      sync_times.sort!
      sync_times.last
    end

    def cancel_sync
      Rails.logger.info "Canceling synchronization of product #{self.label}"
      for r in repos(library)
        r.cancel_sync
      end
    end

    def repo_id(content_name, env_label = nil)
      return content_name if content_name.include?(self.organization.label) && content_name.include?(self.label.to_s)
      Repository.repo_id(self.label.to_s, content_name.to_s, env_label, self.organization.label, nil)
    end

    def repo_url(content_url)
      if self.provider.provider_type == Provider::CUSTOM
        url = content_url.dup
      else
        url = self.provider[:repository_url] + content_url
      end
      url
    end

    def update_repositories
      org = self.organization
      repos = self.repos(org.library, true, org.default_content_view)
      key = self.key
      cert = self.certificate
      ca = File.read(Resources::CDN::CdnResource.ca_file)
      repos.each do |repo|
        repo.refresh_pulp_repo(ca, cert, key)
      end
    end

    def add_repo(label, name, url, repo_type, unprotected=false, gpg = nil)
      check_for_repo_conflicts(name, label)
      key = EnvironmentProduct.find_or_create(self.organization.library, self)
      repo = Repository.create!(:environment_product => key, :pulp_id => repo_id(label),
          :relative_path => Glue::Pulp::Repos.custom_repo_path(self.library, self, label),
          :arch => arch,
          :name => name,
          :label => label,
          :feed => url,
          :gpg_key => gpg,
          :unprotected => unprotected,
          :content_type => repo_type,
          :content_view_version=>self.organization.library.default_content_view_version
      )
      self.organization.default_content_view.update_cp_content(self.organization.library)
      repo.generate_metadata
      repo
    end

    def setup_sync_schedule
      schedule = (self.sync_plan && self.sync_plan.schedule_format) || nil
      self.repos(self.library).each do |repo|
        repo.set_sync_schedule(schedule)
      end
    end

    def repositories_cdn_import_failed!
      set_repositories_cdn_import false
    end

    def repositories_cdn_import_passed!
      set_repositories_cdn_import true
    end

    # update flag skipping all callbacks (hence orchestration)
    # after upgrade to >= 3.1.0 we could use #update_column
    def set_repositories_cdn_import(value)
      self.class.where(:id => self.id).update_all(:cdn_import_success => value)
    end

    def del_repos
      #destroy all repos in all environments
      Rails.logger.debug "deleting all repositories in product #{self.label}"
      self.environment_products.destroy_all
      true
    end


    def custom_repos_create_orchestration
      pre_queue.create(:name => "create pulp repositories for product: #{self.label}",      :priority => 1, :action => [self, :set_repos])
    end

    def save_repos_orchestration
      case orchestration_for
        when :create
          # no repositories are added when a product is created
        when :update
          #called when sync schedule changed, repo added, repo deleted
          pre_queue.create(:name => "setting up pulp sync schedule for product: #{self.label}", :priority => 2, :action => [self, :setup_sync_schedule])
        when :promote
          # do nothing, as repos have already been promoted (see promote_repos method)
      end
    end

    def destroy_repos_orchestration
      pre_queue.create(:name => "delete pulp repositories for product: #{self.label}", :priority => 6, :action => [self, :del_repos])
    end

    protected
    def promote_repos repos, from_env, to_env
      async_tasks = []
      repos.each do |repo|
        async_tasks << repo.promote(from_env, to_env)
      end
      async_tasks.flatten(1)
    end

    def check_for_repo_conflicts(repo_name, repo_label)
      is_dupe =  Repository.joins(:environment_product).where( :name=> repo_name,
              "environment_products.product_id" => self.id, "environment_products.environment_id"=> self.library.id).count > 0
      if is_dupe
        raise Errors::ConflictException.new(_("Label has already been taken"))
      end
      unless repo_label.blank?
        is_dupe =  Repository.joins(:environment_product).where( :label=> repo_label,
               "environment_products.product_id" => self.id, "environment_products.environment_id"=> self.library.id).count > 0
        if is_dupe
          raise Errors::ConflictException.new(_("Label has already been taken"))
        end
      end
    end

  end
end
