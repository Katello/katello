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

module Glue::Pulp::Repos

  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      before_save :save_repos_orchestration
      before_destroy :destroy_repos_orchestration

      has_and_belongs_to_many :filters, :uniq => true, :before_add => :add_filters_orchestration, :before_remove => :remove_filters_orchestration
    end
  end

  def self.groupid(product, environment)
      [self.product_groupid(product), self.env_groupid(environment), self.env_orgid(product.locker.organization)]
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


  def self.env_orgid(org)
      "org:#{org.id}"
  end

  def self.env_groupid(environment)
      "env:#{environment.id}"
  end

  def self.product_groupid(product)
      "product:#{product.cp_id}"
  end

  module InstanceMethods

    def empty?
      return self.repos(locker).empty?
    end

    def repos env, search_params = {}
      @repos = {} if @repos.nil?
      return @repos[env.id] if @repos[env.id]

      # TODO: temporary hack until groupid AND groupid  querying is added to pulp
      total_repos = Pulp::Repository.all [Glue::Pulp::Repos.env_groupid(env)], search_params
      env_repos = []
      total_repos.collect {|repo|
         repo_obj = Glue::Pulp::Repo.new(repo)
         env_repos << repo_obj if (repo_obj.groupid.include?(Glue::Pulp::Repos.product_groupid(self)) and repo_obj.groupid.include?(Glue::Pulp::Repos.env_groupid(env)))
      }
      @repos[env.id] = env_repos
      return env_repos
    end

    def promote from_env, to_env
      @orchestration_for = :promote

      async_tasks = promote_repos repos(from_env), to_env
      if !to_env.products.include? self
        self.environments << to_env
      end

      save!
      async_tasks
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

    def find_latest_package_by_name env, name
      latest_pack = nil

      self.repos(env).each do |repo|
        pack = repo.find_latest_package_by_name name

        next if pack.nil?

        if (latest_pack.nil?) or
           (pack[:epoch] > latest_pack[:epoch]) or
           (pack[:epoch] == latest_pack[:epoch] and pack[:release] > latest_pack[:release]) or
           (pack[:epoch] == latest_pack[:epoch] and pack[:release] == latest_pack[:release] and pack[:version] > latest_pack[:version])
          latest_pack = pack
          latest_pack[:repo_id] = repo.id
        end
      end
      latest_pack
    end

    def has_erratum? id
      self.repos(env).each do |repo|
        return true if repo.has_erratum? id
      end
      false
    end

    def promoted_to? target_env
      target_env.products.include? self
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
      return content_name if content_name.include?(self.organization.name) && content_name.include?(self.cp_id.to_s)
      Glue::Pulp::Repo.repo_id(self.cp_id.to_s, content_name.to_s, env_name, self.organization.name)
    end

    def repository_url(content_url, substitutions = {})
      if self.provider.provider_type == Provider::CUSTOM
        url = content_url.dup
      else
        url = self.provider[:repository_url] + content_url
      end
      substitutions.each { |var, val| url.gsub!("$#{var}",val) }
      url
    end

    def delete_repo(name)
      #TODO: delete candlepin content as well
      Pulp::Repository.destroy(repo_id(name))
    end

    def add_repo(name, url)
      repo = Glue::Pulp::Repo.new(:id => repo_id(name),
          :groupid => Glue::Pulp::Repos.groupid(self, self.locker),
          :relative_path => Glue::Pulp::Repos.repo_path(self.locker, self, name),
          :arch => arch,
          :name => name,
          :feed => url
      )
      repo.create
    end

    def setup_sync_schedule
      if self.sync_plan_id_changed?
          self.productContent.each do |pc|
            schedule = (self.sync_plan && self.sync_plan.schedule_format) || ""
            Pulp::Repository.update(repo_id(pc.content.id), {
                :sync_schedule => schedule
            })
          end
      end
    end

    def set_repos
      self.productContent.collect do |pc|
        cert = self.certificate
        key = self.key
        ca = File.open("#{Rails.root}/config/candlepin-ca.crt", 'rb') { |f| f.read }
        archs = self.arch.split(",")
        archs.each do |arch|
          # temporary solution unless pulp supports another archs
          unless %w[noarch i386 i686 ppc64 s390x x86_64].include? arch
            Rails.logger.error("Pulp does not support arch '#{arch}'")
            next
          end
          repo_name = "#{pc.content.name} #{arch}".gsub(/[^a-z0-9\-_ ]/i,"")
          repo = Glue::Pulp::Repo.new(:id => repo_id(repo_name),
                                      :arch => arch,
                                      :relative_path => Glue::Pulp::Repos.repo_path(self.locker, self, pc.content.name),
                                      :name => repo_name,
                                      :feed => repository_url(pc.content.contentUrl, :basearch => arch),
                                      :feed_ca => ca,
                                      :feed_cert => cert,
                                      :feed_key => key,
                                      :groupid => Glue::Pulp::Repos.groupid(self, self.locker),
                                      :preserve_metadata => orchestration_for == :import_from_cp #preserve repo metadata when importing from cp
                                      )
          repo.create
        end
      end
    end

    def update_repos
      return true unless productContent_changed?

      old_content = productContent_change[0].nil? ? [] : productContent_change[0].map {|pc| pc.content.label}
      new_content = productContent_change[1].map {|pc| pc.content.label}

      added_content   = new_content - old_content
      deleted_content = old_content - new_content

      self.productContent.select {|pc| deleted_content.include?(pc.content.label)}.each do |pc|
        Rails.logger.debug "deleting repository #{repo_id(pc.content.name)}"
        Pulp::Repository.destroy(repo_id(pc.content.name))
      end

      self.productContent.select {|pc| added_content.include?(pc.content.label)}.each do |pc|
        if !(self.environments.map(&:name).any? {|name| pc.content.name.include?(name)}) || pc.content.name.include?('Locker')
        Rails.logger.debug "creating repository #{repo_id(pc.content.name)}"
          self.add_repo(pc.content.name, repository_url(pc.content.contentUrl))
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
      if not self.productContent.nil?
        self.productContent.collect do |pc|
          Pulp::Repository.destroy(repo_id(pc.content.name))
        end
      end
      true
    end

    def save_repos_orchestration
      case orchestration_for
        when :create, :import_from_cp
          queue.create(:name => "create pulp repositories for product: #{self.name}", :priority => 6, :action => [self, :set_repos])
          queue.create(:name => "setting up pulp sync schedule for product: #{self.name}",
                              :priority => 7, :action => [self, :setup_sync_schedule]) if self.sync_plan_id_changed?
        when :update
          queue.create(:name => "update pulp repositories for product: #{self.name}", :priority => 6, :action => [self, :update_repos])
          queue.create(:name => "setting up pulp sync schedule for product: #{self.name}",
                              :priority => 7, :action => [self, :setup_sync_schedule]) if self.sync_plan_id_changed?
        when :promote
          # do nothing, as repos have already been promoted (see promote_repos method)
      end
    end

    def destroy_repos_orchestration
      queue.create(:name => "delete pulp repositories for product: #{self.name}", :priority => 6, :action => [self, :del_repos])
    end

    def add_filters_orchestration(added_filter)
      return true unless environments.size > 1 and promoted_to?(locker.successor)

      self.repos(locker.successor).each do |r|
        queue.create(
            :name => "add filter '#{added_filter.pulp_id}' to repo: #{r.id}",
            :priority => 5,
            :action => [self, :set_filter, r, added_filter.pulp_id])
      end

      @orchestration_for = :add_filter
      on_save
    end

    def remove_filters_orchestration(removed_filter)
      return true unless environments.size > 1 and promoted_to?(locker.successor)

      self.repos(locker.successor).each do |r|
        queue.create(
            :name => "remove filter '#{removed_filter.pulp_id}' from repo: #{r.id}",
            :priority => 5,
            :action => [self, :del_filter, r, removed_filter.pulp_id])
      end

      @orchestration_for = :remove_filter
      on_save
    end

    protected
    def promote_repos repos, to_env
      async_tasks = []
      repos.each do |repo|
        if repo.is_cloned_in?(to_env)
          #repo is already cloned, so lets just re-sync it from its parent
          async_tasks << repo.get_clone(to_env).sync
        else
          to_env.prior == locker ?
              async_tasks << repo.promote(to_env, self, filters.collect {|p| p.pulp_id}) :
              async_tasks << repo.promote(to_env, self)

          new_repo_id = repo.clone_id(to_env)
          new_repo_path = Glue::Pulp::Repos.clone_repo_path_for_cp(repo)

          pulp_uri = URI.parse(AppConfig.pulp.url)
          new_productContent = Glue::Candlepin::ProductContent.new({:content => {
              :name => repo.name,
              :contentUrl => new_repo_path,
              :gpgUrl => "",
              :type => "yum",
              :label => new_repo_id,
              :vendor => "Custom"
            }, :enabled => true
          })

          productContent_will_change!
          productContent << new_productContent
        end
      end
      async_tasks.flatten(1)
    end

    def set_filter repo, filter_id
      repo.add_filters [filter_id]
    end

    def del_filter repo, filter_id
      repo.remove_filters [filter_id]
    end
  end
end
