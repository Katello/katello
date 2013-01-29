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

require 'openssl'
require 'util/model_util'

module Glue::Pulp::Repos

  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      before_save :save_repos_orchestration
      before_destroy :destroy_repos_orchestration

      has_and_belongs_to_many :filters, :uniq => true, :before_add => :add_filters_orchestration, :before_remove => :remove_filters_orchestration

      scope :repositories_cdn_import_failed, where(:cdn_import_success => false)
    end
  end

  def self.groupid(product, environment, content = nil)
      groups = [self.product_groupid(product), self.env_groupid(environment), self.org_groupid(product.library.organization)]
      groups << self.content_groupid(content) if content
      groups
  end

  def self.clone_repo_path(repo, environment, for_cp = false)
    org, env, content_path = repo.relative_path.split("/",3)
    if for_cp
      "/#{content_path}"
    else
      "#{org}/#{environment.label}/#{content_path}"
    end
  end

  def self.repo_path_from_content_path(environment, content_path)
    content_path = content_path.sub(/^\//, "")
    path_prefix = [environment.organization.label, environment.label].join("/")
    "#{path_prefix}/#{content_path}"
  end

  # create content for custom repo
  def create_content(repo)
    new_content = ::Candlepin::ProductContent.new({
      :content => {
        :name => repo.name,
        :contentUrl => Glue::Pulp::Repos.custom_content_path(repo.product, repo.label),
        :gpgUrl => repo.yum_gpg_key_url,
        :type => "yum",
        :label => repo.custom_content_label,
        :vendor => Provider::CUSTOM
      },
      :enabled => true
    })
    new_content.create
    add_content new_content
    new_content.content
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
    self.clone_repo_path(repo, nil, true)
  end


  def self.org_groupid(org)
      "org:#{org.id}"
  end

  def self.env_groupid(environment)
      "env:#{environment.id}"
  end

  def self.product_groupid(product)
    if product.is_a? String
      product_id = product
    else
      product_id = product.cp_id
    end
     "product:#{product_id}"
  end

  def self.content_groupid(content)
    if content.is_a? String
      content_id = content
    else
      content_id = content.id
    end
    "content:#{content_id}"
  end

  def self.prepopulate!(products, environment, repos = [])
    items = Resources::Pulp::Repository.all(["env:#{environment.id}"])
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

    def repos(env, include_disabled = false)
      # cache repos so we can cache lazy_accessors
      @repo_cache ||= {}

      @repo_cache[env.id] ||= Repository.joins(:environment_product).where(
          "environment_products.product_id" => self.id,
          "environment_products.environment_id" => env)

      if include_disabled
        @repo_cache[env.id]
      else
        # we only want the enabled repos to be visible
        # This serves as a white list for redhat repos
        @repo_cache[env.id].where(:enabled => true)
      end
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

    def delete_from_env from_env
      @orchestration_for = :delete
      delete_repos(repos(from_env), from_env)
      if from_env.products.include? self
        self.environments.delete(from_env)
      end
      save!
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

      Katello::PackageUtils.find_latest_packages packs
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
      Glue::Pulp::Repo.repo_id(self.label.to_s, content_name.to_s, env_label, self.organization.label)
    end

    def repo_url(content_url)
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

    def add_repo(label, name, url, repo_type, gpg = nil)
      check_for_repo_conflicts(name, label)
      key = EnvironmentProduct.find_or_create(self.organization.library, self)
      repo = Repository.create!(:environment_product => key, :pulp_id => repo_id(label),
          :groupid => Glue::Pulp::Repos.groupid(self, self.library),
          :relative_path => Glue::Pulp::Repos.custom_repo_path(self.library, self, label),
          :arch => arch,
          :name => name,
          :label => label,
          :feed => url,
          :content_type => repo_type,
          :gpg_key => gpg
      )
      content = create_content(repo)
      Resources::Pulp::Repository.update(repo.pulp_id, :addgrp => Glue::Pulp::Repos.content_groupid(content))
      repo.update_attributes!(:cp_label => content.label)
      repo
    end

    def setup_sync_schedule
      schedule = (self.sync_plan && self.sync_plan.schedule_format) || nil
      self.repos(self.library).each do |repo|
        repo.set_sync_schedule(schedule)
      end
    end


    def set_repos
      content_urls = self.productContent.map { |pc| pc.content.contentUrl }
      cdn_var_substitutor = Resources::CDN::CdnResource.new(self.provider[:repository_url],
                                                       :ssl_client_cert => OpenSSL::X509::Certificate.new(self.certificate),
                                                       :ssl_client_key => OpenSSL::PKey::RSA.new(self.key),
                                                       :product        => self).substitutor(self.import_logger)
      begin
        cdn_var_substitutor.precalculate(content_urls)
      rescue Errors::SecurityViolation => e
        # in case we cannot access CDN server to obtain repository URLS we note down error
        self.repositories_cdn_import_failed!
        if self.import_logger
          self.import_logger.error("\nproduct #{self.name} repositories import: " <<
                                       'SecurityViolation occurred when contacting CDN to fetch ' <<
                                       "listing files\n" + e.backtrace.join("\n"))
        end
        # false would cancel orchestration and would lead to product save cancellation
        # but we want import process to succeed
        return true
      end

      self.productContent.collect do |pc|
        ca = File.read(Resources::CDN::CdnResource.ca_file)

        cdn_var_substitutor.substitute_vars(pc.content.contentUrl).each do |(substitutions, path)|
          feed_url = repo_url(path)
          arch = substitutions["basearch"] || "noarch"
          repo_name = [pc.content.name, substitutions.sort_by {|k,_| k.to_s}.map(&:last)].flatten.compact.join(" ").gsub(/[^a-z0-9\-\._ ]/i,"")
          version = Resources::CDN::Utils.parse_version(substitutions["releasever"])

          begin
            env_prod = EnvironmentProduct.find_or_create(self.organization.library, self)
            unless Repository.where(:environment_product_id => env_prod.id, :pulp_id => repo_id(repo_name)).any?
              repo = Repository.create!(:environment_product=> env_prod, :pulp_id => repo_id(repo_name),
                                        :cp_label => pc.content.label,
                                        :arch => arch,
                                        :major => version[:major],
                                        :minor => version[:minor],
                                        :relative_path => Glue::Pulp::Repos.repo_path_from_content_path(self.library, path),
                                        :name => repo_name,
                                        :label => Katello::ModelUtils::labelize(repo_name),
                                        :feed => feed_url,
                                        :feed_ca => ca,
                                        :feed_cert => self.certificate,
                                        :feed_key => self.key,
                                        :content_type => pc.content.type,
                                        :groupid => Glue::Pulp::Repos.groupid(self, self.library, pc.content),
                                        :preserve_metadata => true, #preserve repo metadata when importing from cp
                                        :enabled =>false
                                       )
            end
            self.repositories_cdn_import_passed! unless self.cdn_import_success?

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

    def save_repos_orchestration
      case orchestration_for
        when :create
          # no repositories are added when a product is created
        when :import_from_cp
          pre_queue.create(:name => "create pulp repositories for product: #{self.label}",      :priority => 1, :action => [self, :set_repos])
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

    def add_filters_orchestration(added_filter)
      return true unless environments.size > 1 and promoted_to?(library.successor)

      self.repos(library.successor).each do |r|
        pre_queue.create(
            :name => "add filter '#{added_filter.pulp_id}' to repo: #{r.id}",
            :priority => 5,
            :action => [self, :set_filter, r, added_filter.pulp_id])
      end

      @orchestration_for = :add_filter
      on_save
    end

    def remove_filters_orchestration(removed_filter)
      return true unless environments.size > 1 and promoted_to?(library.successor)

      self.repos(library.successor).each do |r|
        pre_queue.create(
            :name => "remove filter '#{removed_filter.pulp_id}' from repo: #{r.id}",
            :priority => 5,
            :action => [self, :del_filter, r, removed_filter.pulp_id])
      end

      @orchestration_for = :remove_filter
      on_save
    end

    protected
    def promote_repos repos, from_env, to_env
      async_tasks = []
      repos.each do |repo|
        async_tasks << repo.promote(from_env, to_env)
      end
      async_tasks.flatten(1)
    end

    def delete_repos repos, from_env
      repos.each do |repo|
        self.delete_repo(repo, from_env, true)
      end
    end

    # Delete the repo; however, if delete_only_if_last_env is false
    # and the repo is not the in the last environment of the
    # path, simply disable/hide it.
    def delete_repo repo, from_env, delete_only_if_last_env=false
      if delete_only_if_last_env and !from_env.successor.nil? and repo.is_cloned_in?(from_env.successor)
        repo.disable_repo
      else
        self.delete_repo_by_id(repo.id)
      end
    end

    def set_filter repo, filter_id
      repo.set_filters [filter_id]
    end

    def del_filter repo, filter_id
      repo.del_filters [filter_id]
    end

    def check_for_repo_conflicts(repo_name, repo_label)
      is_dupe =  Repository.joins(:environment_product).where( :name=> repo_name,
              "environment_products.product_id" => self.id, "environment_products.environment_id"=> self.library.id).count > 0
      if is_dupe
        raise Errors::ConflictException.new(_("There is already a repo with the name [ %{repo} ] for product [ %{product} ]") % {:repo => repo_name, :product => self.label})
      end

      unless repo_label.blank?
        is_dupe =  Repository.joins(:environment_product).where( :label=> repo_label,
               "environment_products.product_id" => self.id, "environment_products.environment_id"=> self.library.id).count > 0
        if is_dupe
          raise Errors::ConflictException.new(_("There is already a repo with the label [ %{repo} ] for product [ %{product} ]") % {:repo => repo_label, :product => self.label})
        end
      end
    end
  end
end
