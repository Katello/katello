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
    end
  end

  def self.groupid(product, environment)
      [self.product_groupid(product), self.env_groupid(environment), self.env_orgid(product.locker.organization)]
  end

  def self.clone_repo_id(repo, environment)
    [repo.product.cp_id, repo.name, environment.name,environment.organization.name].map{|x| x.gsub(/[^-\w]/,"_") }.join("-")
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

    def repos env
      @repos = {} if @repos.nil?
      return @repos[env.id] if @repos[env.id]

      # TODO: temporary hack until groupid AND groupid  querying is added to pulp
      total_repos = Pulp::Repository.all [Glue::Pulp::Repos.env_groupid(env)]
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

    #is the repo cloned in the specified environment
    def is_cloned_in? repo, env
      return get_cloned(repo, env) != nil
    end

    def get_cloned repo, env
      self.repos(env).each{ |curr_repo|
        return curr_repo if repo.clone_ids.include?(curr_repo.id)
      }
      nil
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
      states = Array.new
      # Get the most recent status from all the repos in this product
      not_synced = ::PulpSyncStatus.new(:state => ::PulpSyncStatus::Status::NOT_SYNCED)
      top_status = not_synced

      for r in repos(self.locker)
        curr_status = r.sync_status()
        repo_sync_state = curr_status.state
        if repo_sync_state == ::PulpSyncStatus::Status::ERROR.to_s
          #if one repo sync failed, consider the product sync failed
          top_status = curr_status

        elsif repo_sync_state == ::PulpSyncStatus::Status::RUNNING.to_s and
              top_status != ::PulpSyncStatus::Status::ERROR.to_s
          #if one repo sync is running and there are no errors so far, consider the product sync running
          top_status = curr_status

        elsif repo_sync_state == ::PulpSyncStatus::Status::FINISHED.to_s and
              top_status  != ::PulpSyncStatus::Status::RUNNING.to_s and
              top_status  != ::PulpSyncStatus::Status::ERROR.to_s
          #if one repo is finished and there are no running or failing repos so far, consider the product sync finished
          top_status = curr_status

        end
      end
      top_status
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

    def repo_id content_id, env_name = nil
      return content_id if content_id.include?(self.organization.name) && content_id.include?(self.cp_id.to_s)
      [self.cp_id.to_s, content_id.to_s, env_name, self.organization.name].compact.join("-").gsub(/[^-\w]/,"_")
    end

    def repository_url content_url
      return content_url if self.provider.provider_type == Provider::CUSTOM
      self.provider[:repository_url] + content_url
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
        repo = Glue::Pulp::Repo.new(:id => repo_id(pc.content.id),
            :arch => arch,
            :relative_path => Glue::Pulp::Repos.repo_path(self.locker, self, pc.content.name),
            :name => pc.content.name,
            :feed => repository_url(pc.content.contentUrl),
            :feed_ca => ca,
            :feed_cert => cert,
            :feed_key => key,
            :groupid => Glue::Pulp::Repos.groupid(self, self.locker)
        )
        repo.create
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
      #  Pulp::Repository.update(repo_id(pc.content.id), {
      #    :feed => repository_url(pc.content.contentUrl)
      #  })
      #end
    end

    # Empty method to allow rollbacks
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

    protected
    def promote_repos repos, to_env
      async_tasks = []
      repos.each do |repo|
        if repo.is_cloned_in?(to_env)
          #repo is already cloned, so lets just re-sync it from its parent
          async_tasks << repo.get_cloned_in(to_env).sync
        else
          async_tasks << repo.promote(to_env, self)

          new_repo_id = Glue::Pulp::Repos.clone_repo_id(repo, to_env)
          new_repo_path = Glue::Pulp::Repos.clone_repo_path_for_cp(repo)

          pulp_uri = URI.parse(AppConfig.pulp.url)
          new_productContent = Glue::Candlepin::ProductContent.new({:content => {
              :name => repo.name,
              :contentUrl => new_repo_path,
              :gpgUrl => "",
              :type => "yum",
              :label => new_repo_id,
              :vendor => "Custom"
            }
          })

          productContent_will_change!
          productContent << new_productContent
        end
      end
      async_tasks.flatten(1)
    end

  end
end
