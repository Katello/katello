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
      before_save :save_repo_orchestration
      before_destroy :destroy_repo_orchestration

      has_and_belongs_to_many :filters, :uniq => true

      lazy_accessor :pulp_repo_facts,
                    :initializer => lambda {
                      if pulp_id
                        Resources::Pulp::Repository.find(pulp_id)
                      end
                    }
      lazy_accessor :importers, :distributors,
                :initializer => lambda {
                  if pulp_id
                      pulp_repo_facts
                  end
                }
      attr_accessor :feed, :feed_cert, :feed_key, :feed_ca

      def self.ensure_sync_notification
        url = AppConfig.post_sync_url
        type = Resources::Pulp::EventNotifier::EventTypes::REPO_SYNC_COMPLETE
        notifs = Resources::Pulp::EventNotifier.list()

        #delete any similar tasks with the wrong url (in case it changed)
        notifs.select{|n| n['event_types'] == [type] && n['notifier_config']['url'] != url}.each do |e|
          Resources::Pulp::EventNotifier.destroy(e['id'])
        end

        #only create a notifier if one doesn't exist with the correct url
        exists = notifs.select{|n| n['event_types'] == [type] && n['notifier_config']['url'] == url}
        Resources::Pulp::EventNotifier.create_rest_notifier(url, [type]) if exists.empty?
      end

    end
  end

  def self.repo_id product_name, repo_name, env_name, organization_name
    [organization_name, env_name, product_name, repo_name].compact.join("-").gsub(/[^-\w]/,"_")
  end

  #repo_pkgs = a map with {repo => [package objects to be removed]}
  def self.delete_repo_packages repo_pkgs
    Resources::Pulp::Repository.delete_repo_packages(make_pkg_tuples(repo_pkgs))
  end

  #repo_pkgs = a map with {repo => [package objects to be added]}
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
          pre_queue.create(:name => "create pulp repo: #{self.name}", :priority => 2, :action => [self, :create_pulp_repo])
      end
    end

    def last_sync
      self.importers.first['config']['last_sync'] if self.importers.first
    end

    def relative_path
      return @relative_path if @relative_path
      self.distributors.first['config']['relative_url'] if self.distributors.first
    end

    def relative_path=(path)
      @relative_path = path
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


  def create_pulp_repo

    #if we are in library, no need for an distributor, but need to sync
    if self.environment.library?
      importer = Resources::Pulp::YumImporter.new(:ssl_ca_cert=>self.feed_ca,
            :ssl_client_cert=>self.feed_cert,
            :ssl_client_key=>self.feed_key,
            :feed_url=>self.feed)
    else
      #if not in library, no need for sync info, but we need a distributor
      importer = Resources::Pulp::YumImporter.new
    end

    distributors = [Resources::Pulp::YumDistributor.new(self.relative_path, true, false,
      {:protected=>true, :generate_metadata=>false, :id=>self.pulp_id,
      :auto_publish=>!self.environment.library?})]

    Resources::Pulp::Repository.create({
        :id => self.pulp_id,
        :display_name => self.name},
        importer,
        distributors
    )
  end



  def promote from_env, to_env
    filters_to_clone = self.filter_pulp_ids_to_promote from_env, to_env

    if self.is_cloned_in?(to_env)
      return clone.sync
    else
      clone_events = self.create_clone(to_env)
      #TODO ensure that clone content is indexed
      #clone.index_packages
      #clone.index_errata
      return clone_events
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

  def del_content
    return true unless self.content_id
    if other_repos_with_same_product_and_content.empty?
      self.product.remove_content_by_id self.content_id
      if other_repos_with_same_content.empty? && !self.product.provider.redhat_provider?
        Resources::Candlepin::Content.destroy(self.content_id)
      end
    end

    true
  end

  def other_repos_with_same_product_and_content
    list = Repository.in_product(Product.find(self.product.id)).where(:content_id=>self.content_id).all
    list.delete(self)
    list
  end

  def other_repos_with_same_content
    list = Repository.where(:content_id=>self.content_id).all
    list.delete(self)
    list
  end

  def destroy_repo_orchestration
    pre_queue.create(:name => "remove product content : #{self.name}", :priority => 2, :action => [self, :del_content])
    pre_queue.create(:name => "delete pulp repo : #{self.name}",       :priority => 3, :action => [self, :destroy_repo])
  end

  def get_params
    return @params.clone
  end

  def packages
    if @repo_packages.nil?
      #we fetch ids and then fetch packages by id, because repo packages
      #  does not contain all the info we need (bz 854260)
      pkg_ids = Resources::Pulp::Repository.package_ids(self.pulp_id)
      self.packages = Resources::Pulp::Package.find_all(pkg_ids)
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
      e_ids = Resources::Pulp::Repository.errata_ids(self.pulp_id)
      self.errata = Resources::Pulp::Errata.find_all_by_unit_ids(e_ids)
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
    Glue::Pulp::Repo.repo_id(self.product.name, self.name, env.name,env.organization.name)
  end


  def set_sync_schedule schedule
    if self.sync_state == "waiting"
        Resources::Pulp::Task.destroy(self.sync_status.uuid)
    end

    if schedule
        Resources::Pulp::Repository.create_or_update_schedule(self.pulp_id, schedule)
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
    Resources::Pulp::Repository.packages_by_nvre self.pulp_id, name
  end

  def find_packages_by_nvre name, version, release, epoch
    Resources::Pulp::Repository.packages_by_nvre self.pulp_id, name, version, release, epoch
  end

  def find_latest_packages_by_name name
    Katello::PackageUtils.find_latest_packages(Resources::Pulp::Repository.packages_by_nvre(self.pulp_id, name))
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

    task = PulpTaskStatus.using_pulp_task(pulp_tasks.first)
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

  def add_packages pkg_id_list
    blacklist = []
    self.applicable_filters.each{|f| blacklist += f.package_list}

    previous = self.environmental_instances.in_environment(self.environment.prior).first

    Resources::Pulp::Repository.package_copy previous.pulp_id, self.pulp_id,  pkg_id_list, blacklist
  end

  def add_errata errata_id_list
    previous = self.environmental_instances.in_environment(self.environment.prior).first
    Resources::Pulp::Repository.errata_copy previous.pulp_id, self.pulp_id,  errata_id_list
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

  def organization
    Organization.find(self.organization_id)
  end

  def content
    if not self.content_id.nil?
      Glue::Candlepin::Content.new(::Resources::Candlepin::Content.get(self.content_id))
    end
  end

  def generate_metadata
    ::Resources::Pulp::Repository.publish(self.pulp_id)
  end

  # Convert array of Repo objects to Ruby Hash in the form of repo.id => repo_object for fast searches.
  #
  # @param array_to_hash array of Repo objects
  # @returns Hash structure
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
    rescue Exception=>e
        history = Resources::Pulp::Repository.sync_history(pulp_id)
    end

    if history.nil? or history.empty?
      return ::PulpSyncStatus.new(:state => ::PulpSyncStatus::Status::NOT_SYNCED)
    else
      history = sort_sync_status(history)
      return PulpSyncStatus.pulp_task(history.first.with_indifferent_access)
    end
  end


  end

end
