#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'http_resource'
require 'resources/pulp'
require 'resources/cdn'
require 'openssl'

module Glue::Pulp::Repos

  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      before_save :save_repos_orchestration
      before_destroy :destroy_repos_orchestration
    end
  end

  def self.groupid(product, environment, content = nil)
      groups = [self.product_groupid(product), self.env_groupid(environment), self.org_groupid(product.locker.organization)]
      groups << self.content_groupid(content) if not content.nil?
      groups
  end

  def self.clone_repo_path(repo, environment, for_cp = false)
    repo_path(environment,repo.product, repo.name, for_cp)
  end

  # if for_cp tells it's used for contentUrl in candlepin
  # CP computes the rest of path automaticly - it does not to be specified here
  def self.repo_path(environment, product, name, for_cp = false)
    parts = []
    parts += [environment.organization.name,environment.name] unless for_cp
    parts += [product.name,name]
    parts.map{|x| x.gsub(/[^-\w]/,"_") }.join("/")
  end

  def self.clone_repo_path_for_cp(repo)
    self.clone_repo_path(repo, nil, true)
  end


  def self.org_groupid(org)
      "org:#{org.id}"
  end

  def self.env_groupid(environment)
      "env:#{environment.id}"
  end

  def self.product_groupid(product)
      "product:#{product.cp_id}"
  end

  def self.content_groupid(product_content)
      "content:#{product_content.content.id}"
  end

  module InstanceMethods

    def empty?
      return self.repos(locker).empty?
    end


    def repos env
      Repository.joins(:environment_product).where(
            "environment_products.product_id" => self.id, "environment_products.environment_id"=> env)
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

    def find_latest_packages_by_name env, name

      packs = self.repos(env).collect do |repo|
        repo.find_latest_packages_by_name(name).collect do |pack|
          pack[:repo_id] = repo.id
          pack
        end
      end.flatten(1)

      Katello::PackageUtils.find_latest_packages packs
    end

    def has_erratum? id
      self.repos(env).each do |repo|
        return true if repo.has_erratum? id
      end
      false
    end

    def sync
      Rails.logger.info "Syncing product #{name}"
      self.repos(locker).collect do |r|
        r.sync
      end.flatten
    end

    def synced?
      self.repos(locker).any? { |r| r.synced? }
    end

    #get last sync status of all repositories in this product
    def latest_sync_statuses
      self.repos(locker).collect do |r|
        r._get_most_recent_sync_status()
      end
    end

    # Get the most relavant status for all the repos in this Product
    def sync_status
      return @status if @status

      statuses = repos(self.locker).map {|r| r.sync_status()}
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
      for r in repos(locker)
        start = r.sync_start
        start_times << start unless start.nil?
      end
      start_times.sort!
      start_times.last
    end

    def sync_finish
      finish_times = Array.new
      for r in repos(locker)
        finish = r.sync_finish
        finish_times << finish unless finish.nil?
      end
      finish_times.sort!
      finish_times.last
    end

    def sync_size
      size = self.repos(locker).inject(0) { |sum,v| sum + v.sync_status.progress.total_size }
    end

    def last_sync
      sync_times = Array.new
      for r in repos(locker)
        sync = r.last_sync
        sync_times << sync unless sync.nil?
      end
      sync_times.sort!
      sync_times.last
    end

    def cancel_sync
      Rails.logger.info "Cancelling synchronization of product #{name}"
      for r in repos(locker)
        r.cancel_sync
      end
    end

    def repo_id(content_name, env_name = nil)
      return content_name if content_name.include?(self.organization.name) && content_name.include?(self.name.to_s)
      Glue::Pulp::Repo.repo_id(self.name.to_s, content_name.to_s, env_name, self.organization.name)
    end

    def repository_url(content_url)
      if self.provider.provider_type == Provider::CUSTOM
        url = content_url.dup
      else
        url = self.provider[:repository_url] + content_url
      end
      url
    end

    def delete_repo_by_id(repo_id)
      Repository.destroy_all(:id=>repo_id)
    end

    def add_repo(name, url, repo_type)
      check_for_repo_conflicts(name)
      key = EnvironmentProduct.find_or_create(self.organization.locker, self)
      repo = Repository.create!(:environment_product => key, :pulp_id => repo_id(name),
          :groupid => Glue::Pulp::Repos.groupid(self, self.locker),
          :relative_path => Glue::Pulp::Repos.repo_path(self.locker, self, name),
          :arch => arch,
          :name => name,
          :feed => url,
          :content_type => repo_type
      )
    end

    def setup_sync_schedule
      return true if not self.sync_plan_id_changed?

      schedule = (self.sync_plan && self.sync_plan.schedule_format) || ""
      self.all_repos.each do |repo|
        repo.set_sync_schedule(schedule)
      end
    end

    def set_repos
      self.productContent.collect do |pc|
        cert = self.certificate
        key = self.key
        ca = File.read(CDN::CdnResource.ca_file)

        cdn_var_substitutor = CDN::CdnVarSubstitutor.new(self.provider[:repository_url],
                                                         :ssl_client_cert => OpenSSL::X509::Certificate.new(cert),
                                                         :ssl_client_key => OpenSSL::PKey::RSA.new(key))
        substitutions_with_paths = cdn_var_substitutor.substitute_vars(pc.content.contentUrl)

        substitutions_with_paths.each do |(substitutions, path)|

          feed_url = repository_url(path)
          arch = substitutions["basearch"] || "noarch"
          repo_name = [pc.content.name, substitutions.values].flatten.compact.join(" ").gsub(/[^a-z0-9\-_ ]/i,"")
          begin
            env_prod = KtEnvironmentProduct.find_or_create(self.organization.locker, self)
            repo = Repository.create!(:environment_product=> env_prod, :pulp_id => repo_id(repo_name),
                                        :arch => arch,
                                        :relative_path => Glue::Pulp::Repos.repo_path(self.locker, self, repo_name),
                                        :name => repo_name,
                                        :feed => feed_url,
                                        :feed_ca => ca,
                                        :feed_cert => cert,
                                        :feed_key => key,
                                        :content_type => pc.content.type,
                                        :groupid => Glue::Pulp::Repos.groupid(self, self.locker),
                                        :preserve_metadata => orchestration_for == :import_from_cp #preserve repo metadata when importing from cp
                                        )

          rescue RestClient::InternalServerError => e
            if e.message.include? "Architecture must be one of"
              Rails.logger.error("Pulp does not support arch '#{arch}'")
            else
              raise e
            end
          end
        end
      end
    end

    def update_repos
      return true unless productContent_changed?

      deleted_content.each do |pc|
        Rails.logger.debug "deleting repository #{pc.content.label}"
        Repository.destroy_all(:pulp_id => repo_id(pc.content.name))
      end

      added_content.each do |pc|
        if !(self.environments.map(&:name).any? {|name| pc.content.name.include?(name)}) || pc.content.name.include?('Locker')
          Rails.logger.debug "creating repository #{repo_id(pc.content.name)}"
          self.add_repo(pc.content.name, repository_url(pc.content.contentUrl), pc.content.type)
        else
          raise "new content was added to environment other than Locker. use promotion instead."
        end
      end

      #
      # TODO: candlepin currently doesn't support modification of content
      #
      #common_content_ids = (old_content_ids & new_content_ids)
      #changed_content = self.productContent_change[1].select do |new_pc|
      #  common_content_ids.include?(new_pc.id) && productContent_change[0].any? do |old_pc|
      #    old_pc.id == new_pc.id && old_pc.content.contentUrl != new_pc.content.contentUrl
      #  end
      #end
      #
      #changed_content.each do |pc|
      #  Pulp::Repository.update(repo_id(pc.content.name), {
      #    :feed => repository_url(pc.content.contentUrl)
      #  })
      #end
    end

    def del_repos
      #destroy all repos in all environmnents
      Rails.logger.debug "deleting all repositoris in product #{name}"
      self.environments.each do |env|
        self.repos(env).each do |repo|
          repo.destroy
        end
      end
      true
    end

    def save_repos_orchestration
      case orchestration_for
        when :create
          # no repositories are added when a product is created
        when :import_from_cp
          queue.create(:name => "create pulp repositories for product: #{self.name}",      :priority => 1, :action => [self, :set_repos])
        when :update
          #called when sync schedule changed, repo added, repo deleted
          queue.create(:name => "setting up pulp sync schedule for product: #{self.name}", :priority => 2, :action => [self, :setup_sync_schedule])
        when :promote
          # do nothing, as repos have already been promoted (see promote_repos method)
      end
    end

    def destroy_repos_orchestration
      queue.create(:name => "delete pulp repositories for product: #{self.name}", :priority => 6, :action => [self, :del_repos])
    end

    protected
    def promote_repos repos, from_env, to_env
      async_tasks = []
      repos.each do |repo|
        if repo.is_cloned_in?(to_env)
          #repo is already cloned, so lets just re-sync it from its parent
          async_tasks << repo.get_clone(to_env).sync
        else
          #repo is not in the next environment yet, we have to clone it there
          content = self.content_for_clone_of repo
          new_repo = repo.promote(to_env, self)
          async_tasks << new_repo.clone_response
        end
      end
      async_tasks.flatten(1)
    end


    def content_for_clone_of repo
      return repo.content unless repo.content_id.nil?

      new_repo_path = Glue::Pulp::Repos.clone_repo_path_for_cp(repo)
      new_content = self.create_content(repo.name, new_repo_path)

      self.add_content new_content
      new_content
    end


    def create_content name, path
      new_content = Glue::Candlepin::ProductContent.new({
        :content => {
          :name => name,
          :contentUrl => path,
          :gpgUrl => "",
          :type => "yum",
          :label => name,
          :vendor => "Custom"
        },
        :enabled => true
      })
      new_content.create
      new_content
    end

    def check_for_repo_conflicts(repo_name)
      is_dupe =  Repository.joins(:environment_product).where( :name=> repo_name,
              "environment_products.product_id" => self.id, "environment_products.environment_id"=> self.locker.id).count > 0
      if is_dupe
        raise Errors::ConflictException.new(_("There is already a repo with the name [ %s ] for product [ %s ]") % [repo_name, self.name])
      end
    end
  end
end
