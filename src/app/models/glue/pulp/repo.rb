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

module Glue::Pulp::Repo
  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do
      before_validation :setup_repo_clone
      before_save :save_repo_orchestration
      before_destroy :destroy_repo_orchestration

      has_and_belongs_to_many :filters, :uniq => true, :before_add => :add_filters_orchestration, :before_remove => :remove_filters_orchestration

      lazy_accessor :pulp_repo_facts,
                    :initializer => lambda {|s|
                      if pulp_id
                        Resources::Pulp::Repository.find(pulp_id)
                      end
                    }
      lazy_accessor :groupid, :arch, :feed, :feed_cert, :feed_key, :feed_ca, :source, :package_count,
                :clone_ids, :uri_ref, :last_sync, :relative_path, :preserve_metadata, :content_type, :uri,
                :initializer => lambda {|s|
                  if pulp_id
                      pulp_repo_facts
                  end
                }
      attr_accessor :clone_from, :clone_response, :cloned_filters, :cloned_content
    end
  end

  def self.repo_id product_label, repo_label, env_label, organization_label
    [organization_label, env_label, product_label, repo_label].compact.join("-").gsub(/[^-\w]/,"_")
  end

  # @param [Hash] repo_pkgs a map with `{repo => [package objects to be removed]}`
  def self.delete_repo_packages repo_pkgs
    Resources::Pulp::Repository.delete_repo_packages(make_pkg_tuples(repo_pkgs))
  end

  # @param [Hash] repo_pkgs a map with `{repo => [package objects to be added]}`
  def self.add_repo_packages repo_pkgs
    Resources::Pulp::Repository.add_repo_packages(make_pkg_tuples(repo_pkgs))
  end

  def self.make_pkg_tuples repo_pkgs
    package_tuples = []
    repo_pkgs.each do |repo, pkgs|
      pkgs.each do |pack|
        package_tuples << [[pack.filename,pack.checksum.to_hash.values.first],[repo.pulp_id]]
      end
    end
    package_tuples
  end


  module InstanceMethods
    def save_repo_orchestration
      case orchestration_for
        when :create
          pre_queue.create(:name => "create pulp repo: #{self.name}", :priority => 2, :action => [self, :clone_or_create_repo])
      end
    end

    def initialize(attrs = nil)
      if attrs.nil?
        super
      elsif
        type_key = attrs.has_key?('type') ? 'type' : :type
        #rename "type" to "cp_type" (activerecord and candlepin variable name conflict)
        #if attrs.has_key?(type_key) && !(attrs.has_key?(:cp_type) || attrs.has_key?('cp_type'))
        #  attrs[:cp_type] = attrs[type_key]
        #end

        attrs_used_by_model = attrs.reject do |k, v|
          !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
        super(attrs_used_by_model)
      end
    end

  def to_hash
    pulp_repo_facts.merge(as_json).merge(:sync_state=> sync_state)
  end

  TYPE_YUM = "yum"
  TYPE_LOCAL = "local"


  def add_filters_orchestration(added_filter)
    return true if not self.environment.library?

    self.clone_ids.each do |clone_id|
      repo = Repository.find_by_pulp_id(clone_id)

      pre_queue.create(
        :name => "add filter '#{added_filter.pulp_id}' to repo: #{repo.id}",
        :priority => 2,
        :action => [repo, :set_filters, [added_filter.pulp_id]]
      )
    end

    @orchestration_for = :add_filter
    on_save
  end

  def remove_filters_orchestration(removed_filter)
    return true if not self.environment.library?

    self.clone_ids.each do |clone_id|
      repo = Repository.find_by_pulp_id(clone_id)

      pre_queue.create(
        :name => "remove filter '#{removed_filter.pulp_id}' from repo: #{repo.id}",
        :priority => 2,
        :action => [repo, :del_filters, [removed_filter.pulp_id]]
      )
    end

    @orchestration_for = :remove_filter
    on_save
  end

  def clone_or_create_repo
    if clone_from
      clone_repo
    else
      create_pulp_repo
    end
  end

  def create_pulp_repo
    feed_cert_data = {:ca => self.feed_ca,
        :cert => self.feed_cert,
        :key => self.feed_key
    }
    Resources::Pulp::Repository.create({
        :id => self.pulp_id,
        :name => self.label,
        :relative_path => self.relative_path,
        :arch => self.arch,
        :feed => self.feed,
        :feed_cert_data => feed_cert_data,
        :groupid => self.groupid,
        :preserve_metadata => self.preserve_metadata == true,
        :content_types => self.content_type || TYPE_YUM
    })
  end

  def promote from_env, to_env
    filters_to_clone = self.filter_pulp_ids_to_promote from_env, to_env

    if self.is_cloned_in?(to_env)
      #repo is already cloned, so lets just re-sync it from its parent
      clone = self.get_clone(to_env)

      # enable the repo, if it is currently disabled.  it is possible for the repo to be
      # disabled, if the user deleted it from the middle of an environment path
      key = EnvironmentProduct.find_or_create(to_env, self.product)
      clone.environment_product = key
      clone.enable_repo

      return clone.sync
    else
      #repo is not in the next environment yet, we have to clone it there
      key = EnvironmentProduct.find_or_create(to_env, self.product)
      library = self.environment.library? ? self : self.library_instance
      clone = Repository.create!(:environment_product => key,
                                 :clone_from => self,
                                 :cloned_content => self.content,
                                 :cloned_filters => filters_to_clone,
                                 :cp_label => self.cp_label,
                                 :library_instance=>library)

      clone.index_packages
      clone.index_errata

      return clone.clone_response
    end
  end

  def filter_pulp_ids_to_promote from_env, to_env
    if from_env.library?
      filters_to_clone = self.filters + self.product.filters
      filters_to_clone = filters_to_clone.uniq.collect {|f| f.pulp_id}
    else
      filters_to_clone = []
    end
    filters_to_clone
  end

  def setup_repo_clone
    if clone_from
      self.pulp_id = clone_from.clone_id(environment_product.environment)
      self.relative_path = Glue::Pulp::Repos.clone_repo_path(clone_from, environment_product.environment)
      self.arch = clone_from.arch
      self.name = clone_from.name
      self.label = clone_from.label
      self.feed = clone_from.feed
      self.major = clone_from.major
      self.minor = clone_from.minor
      self.groupid = Glue::Pulp::Repos.groupid(environment_product.product, environment_product.environment, cloned_content)
      self.enabled = clone_from.enabled
    end
  end

  def clone_repo
    self.clone_response = [Resources::Pulp::Repository.clone_repo(clone_from, self, "parent", cloned_filters)]
  end

  def populate_from repos_map
    found = repos_map[self.pulp_id]
    prepopulate(found) if found
    !found.nil?
  end

  def enable_repo
    if !self.enabled
      # publish and enable the repo
      repo = self.readonly? ? Repository.find(self.id) : self
      Resources::Pulp::Repository.update_publish(repo.pulp_id, true)
      repo.enabled = true
      repo.save!
    end
  end

  def disable_repo
    if self.enabled
      # unpublish and disable the repo
      repo = self.readonly? ? Repository.find(self.id) : self
      Resources::Pulp::Repository.update_publish(repo.pulp_id, false)
      repo.enabled = false
      repo.save!
    end
  end

  def destroy_repo
    self.update_packages_index
    self.update_errata_index
    Resources::Pulp::Repository.destroy(self.pulp_id)
    true
  end

  def other_repos_with_same_product_and_content
    product_group_id = Glue::Pulp::Repos.product_groupid(self.product_id)
    content_group_id = Glue::Pulp::Repos.content_groupid(self.content_id)
    Resources::Pulp::Repository.all([content_group_id, product_group_id]).map{|r| r['id']} - [self.pulp_id]
  end

  def other_repos_with_same_content
    content_group_id = Glue::Pulp::Repos.content_groupid(self.content_id)
    Resources::Pulp::Repository.all([content_group_id]).map{|r| r['id']} - [self.pulp_id]
  end

  def destroy_repo_orchestration
    pre_queue.create(:name => "delete pulp repo : #{self.name}", :priority => 3, :action => [self, :destroy_repo])
  end

  def get_params
    return @params.clone
  end

  def packages
    if @repo_packages.nil?
      self.packages = Resources::Pulp::Repository.packages(self.pulp_id)
    end
    @repo_packages
  end

  def packages=attrs
    @repo_packages = attrs.collect do |package|
        Glue::Pulp::Package.new(package)
    end
    @repo_packages
  end

  def errata
    if @repo_errata.nil?
       self.errata = Resources::Pulp::Repository.errata(self.pulp_id)
    end
    @repo_errata
  end

  def errata=attrs
    @repo_errata = attrs.collect do |erratum|
        Glue::Pulp::Errata.new(erratum)
    end
    @repo_errata
  end

  def distributions
    if @repo_distributions.nil?
      self.distributions = Resources::Pulp::Repository.distributions(self.pulp_id)
    end
    @repo_distributions
  end

  def distributions=attrs
    @repo_distributions = attrs.collect do |dist|
        Glue::Pulp::Distribution.new(dist)
    end
    @repo_distributions
  end

  def has_distribution? id
    self.distributions.each {|distro|
      return true if distro.id == id
    }
    return false
  end

  def package_groups search_args = {}
    groups = ::Resources::Pulp::PackageGroup.all self.pulp_id
    unless search_args.empty?
      groups.delete_if do |group_id, group_attrs|
        search_args.any?{ |attr,value| group_attrs[attr] != value }
      end
    end
    groups.values
  end

  def package_group_categories search_args = {}
    categories = ::Resources::Pulp::PackageGroupCategory.all self.pulp_id
    unless search_args.empty?
      categories.delete_if do |category_id, category_attrs|
        search_args.any?{ |attr,value| category_attrs[attr] != value }
      end
    end
    categories.values
  end

  def clone_id(env)
    Glue::Pulp::Repo.repo_id(self.product.label, self.label, env.label, env.organization.label)
  end

  #is the repo cloned in the specified environment
  def is_cloned_in? env
    clone_id = self.clone_id(env)
    self.clone_ids.include? clone_id
  end

  def promoted?
    !self.clone_ids.empty?
  end

  def get_clone env
    Repository.find_by_pulp_id(self.clone_id(env))
  rescue
    nil
  end

  def set_sync_schedule schedule
    if self.sync_state == "waiting"
        Resources::Pulp::Task.destroy(self.sync_status.uuid)
    end

    if schedule
        Resources::Pulp::Repository.update_schedule(self.pulp_id, schedule)
    else
        Resources::Pulp::Repository.delete_schedule(self.pulp_id)
    end
  end

  def has_package? id
    self.packages.each {|pkg|
      return true if pkg.id == id
    }
    return false
  end

  def find_packages_by_name name
    Resources::Pulp::Repository.packages_by_name self.pulp_id, name
  end

  def find_packages_by_nvre name, version, release, epoch
    Resources::Pulp::Repository.packages_by_nvre self.pulp_id, name, version, release, epoch
  end

  def find_latest_packages_by_name name
    Katello::PackageUtils.find_latest_packages(Resources::Pulp::Repository.packages_by_name(self.pulp_id, name))
  end

  def has_erratum? id
    self.errata.each {|err|
      return true if err.id == id
    }
    return false
  end

  def sync(options = { })
    pulp_task = Resources::Pulp::Repository.sync(self.pulp_id)
    task      = PulpSyncStatus.using_pulp_task(pulp_task) do |t|
      t.organization         = self.environment.organization
      t.parameters ||= {}
      t.parameters[:options] = options
    end
    task.save!
    return [task]
  end

  def after_sync pulp_task_id
    pulp_tasks =  Resources::Pulp::Task.find([pulp_task_id])

    if pulp_tasks.empty?
      Rails.logger.error("Sync_complete called for #{pulp_task_id}, but no task found.")
      return
    end

    task = PulpSyncStatus.pulp_task(pulp_tasks.first)
    task.user ||= User.current
    task.organization ||= self.environment.organization
    task.save!

    self.sync_complete(task)
    self.index_packages
    self.index_errata
  end


  def sync_start
    status = self.sync_status
    retval = nil
    if status.nil? or status.start_time.nil?
      retval = nil
    else
      retval = status.start_time
      # retval = date.strftime("%H:%M:%S %Y-%m-%d")
    end
    retval
  end

  def add_errata errata_id_list
    Resources::Pulp::Repository.add_errata self.pulp_id,  errata_id_list
  end

  def add_distribution distribution_id
    Resources::Pulp::Repository.add_distribution self.pulp_id,  distribution_id
  end

  def delete_errata errata_id_list
    Resources::Pulp::Repository.delete_errata self.pulp_id,  errata_id_list
  end

  def delete_distribution distribution_id
    Resources::Pulp::Repository.delete_distribution self.pulp_id,  distribution_id
  end

  def cancel_sync
    Rails.logger.info "Cancelling synchronization of repository #{self.pulp_id}"
    history = self.sync_status
    return if history.nil? || history.state == ::PulpSyncStatus::Status::NOT_SYNCED

    Resources::Pulp::Task.cancel(history.uuid)
  end

  def sync_finish
    status = self.sync_status
    retval = nil
    if status.nil? or status.finish_time.nil?
      retval = nil
    else
      retval = status.finish_time
    end
    retval
  end

  def sync_status
    self._get_most_recent_sync_status() if @sync_status.nil?
  end

  def sync_state
    status = sync_status
    return ::PulpSyncStatus::Status::NOT_SYNCED if status.nil?
    status.state
  end

  def synced?
    sync_history = self.sync_status
    !sync_history.nil? && successful_sync?(sync_history)
  end

  def successful_sync?(sync_history_item)
    sync_history_item['state'] == 'finished'
  end

  def organization_id
    self.organization.id
  end

  def environment_id
    self.environment.id
  end

  def product_id
    get_groupid_param 'product'
  end

  def content_id
    get_groupid_param 'content'
  end

  def organization
    Organization.find(self.organization_id)
  end

  def set_filters filter_ids
    ::Resources::Pulp::Repository.add_filters self.pulp_id, filter_ids
  end

  def del_filters filter_ids
    ::Resources::Pulp::Repository.remove_filters self.pulp_id, filter_ids
  end

  def generate_metadata
    ::Resources::Pulp::Repository.generate_metadata(self.pulp_id)
  end

  # Convert array of Repo objects to Ruby Hash in the form of repo.id => repo_object for fast searches.
  #
  # @param [Array] array_of_repos array of Repo objects
  # @return Hash structure
  def self.array_to_hash(array_of_repos)
    Hash[*array_of_repos.collect { |r|
      [r.id, r]
    }.flatten]
  end

  def sort_sync_status statuses
    statuses.sort!{|a,b|
      if a['finish_time'].nil? && b['finish_time'].nil?
        if a['start_time'].nil?
          1
        elsif b['start_time'].nil?
          -1
        else
          a['start_time'] <=> b['start_time']
        end
      elsif a['finish_time'].nil?
        if a['start_time'].nil?
          1
        else
          -1
        end
      elsif b['finish_time'].nil?
        if b['start_time'].nil?
          -1
        else
          1
        end
      else
        b['finish_time'] <=> a['finish_time']
      end
    }

    return statuses
  end

  protected

  def _get_most_recent_sync_status()
    begin
      history = Resources::Pulp::Repository.sync_status(pulp_id)

      if history.nil? or history.empty?
        history = Resources::Pulp::Repository.sync_history(pulp_id)
      end
    rescue
        history = Resources::Pulp::Repository.sync_history(pulp_id)
    end

    if history.nil? or history.empty?
      return ::PulpSyncStatus.new(:state => ::PulpSyncStatus::Status::NOT_SYNCED)
    else
      history = sort_sync_status(history)
      return PulpSyncStatus.pulp_task(history.first.with_indifferent_access)
    end
  end

  private

  def get_groupid_param name
    idx = self.groupid.index do |s| s.start_with? name+':' end
    if not idx.nil?
      return self.groupid[idx].split(':')[1]
    else
      return nil
    end
  end
  end

end
