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
require 'resources/pulp'

module Glue::Pulp::Repo
  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do
    before_validation :setup_repo_clone
      before_save :save_repo_orchestration
      before_destroy :destroy_repo_orchestration
      lazy_accessor :pulp_repo_facts,
                    :initializer => lambda {
                      if pulp_id
                        Pulp::Repository.find(pulp_id)
                      end
                    }
      lazy_accessor :groupid, :arch, :feed, :feed_cert, :feed_key, :feed_ca, :source, :filters,
                :clone_ids, :uri_ref, :last_sync, :relative_path, :preserve_metadata, :content_type,
                :initializer => lambda {
                  if pulp_id
                      pulp_repo_facts
                  end
                }
      attr_accessor :clone_from, :clone_response, :cloned_filters, :cloned_content
    end
  end

  def self.repo_id product_name, repo_name, env_name, organization_name
    [organization_name, env_name, product_name, repo_name].compact.join("-").gsub(/[^-\w]/,"_")
  end


  module InstanceMethods
    def save_repo_orchestration
      case orchestration_for
        when :create
          queue.create(:name => "create pulp repo: #{self.name}", :priority => 2, :action => [self, :clone_or_create_repo])
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
    Pulp::Repository.create({
        :id => self.pulp_id,
        :name => self.name,
        :relative_path => self.relative_path,
        :arch => self.arch,
        :feed => self.feed,
        :feed_cert_data => feed_cert_data,
        :groupid => self.groupid,
        :preserve_metadata => self.preserve_metadata == true,
        :content_types => self.content_type || TYPE_YUM
    })
  end

  def promote(to_environment, filters = [])

    key = EnvironmentProduct.find_or_create(to_environment, self.product)
    repo = Repository.create!(:environment_product => key, :clone_from => self,
                            :cloned_content => self.content_for_clone, :cloned_filters => filters)
    repo.clone_response
  end

  def setup_repo_clone
    if clone_from
      self.pulp_id = clone_from.clone_id(environment_product.environment)
      self.relative_path = Glue::Pulp::Repos.clone_repo_path(clone_from, environment_product.environment)
      self.arch = clone_from.arch
      self.name = clone_from.name
      self.feed = clone_from.feed
      self.major = clone_from.major
      self.minor = clone_from.minor
      self.groupid = Glue::Pulp::Repos.groupid(environment_product.product, environment_product.environment, cloned_content)
      self.enabled = clone_from.enabled
    end
  end

  def clone_repo
    self.clone_response = [Pulp::Repository.clone_repo(clone_from, self, "parent", cloned_filters)]
  end

  def populate_from list
    found = list.find{|repo|
      repo["id"] == self.pulp_id}
    prepopulate(found) if found
    !found.nil?
  end

  def destroy_repo
    Pulp::Repository.destroy(self.pulp_id)
    true
  end

  def del_content
    return true if self.content.nil?
    content_group_id = Glue::Pulp::Repos.content_groupid(self.content)

    content_repo_ids = Pulp::Repository.all([content_group_id]).map{|r| r['id']}
    other_content_repo_ids = (content_repo_ids - [self.pulp_id])

    if other_content_repo_ids.empty?
      self.product.remove_content_by_id self.content_id
    end
    true
  end

  def destroy_repo_orchestration
    queue.create(:name => "remove product content : #{self.name}", :priority => 1, :action => [self, :del_content])
    queue.create(:name => "delete pulp repo : #{self.name}",       :priority => 2, :action => [self, :destroy_repo])
  end

  # TODO: remove after pulp >= 0.0.401 get's released. There is this attribute
  # directly in the repo API
  def uri
    if repo_base_path = AppConfig.pulp.url[/^(.*)api$/,1]
      return "#{repo_base_path}repos/#{self.relative_path}"
    else
      raise "We expect #{AppConfig.pulp.url} to end with 'api' suffix"
    end
  end

  def get_params
    return @params.clone
  end

  def packages
    if @repo_packages.nil?
      self.packages = Pulp::Repository.packages(self.pulp_id)
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
       self.errata = Pulp::Repository.errata(self.pulp_id)
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
      self.distributions = Pulp::Repository.distributions(self.pulp_id)
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
    groups = ::Pulp::PackageGroup.all self.pulp_id
    unless search_args.empty?
      groups.delete_if do |group_id, group_attrs|
        search_args.any?{ |attr,value| group_attrs[attr] != value }
      end
    end
    groups.values
  end

  def package_group_categories search_args = {}
    categories = ::Pulp::PackageGroupCategory.all self.pulp_id
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
    Pulp::Repository.update(self.id, {
      :sync_schedule => schedule
    })
  end

  def has_package? id
    self.packages.each {|pkg|
      return true if pkg.id == id
    }
    return false
  end

  def find_packages_by_name name
    Pulp::Repository.packages_by_name self.pulp_id, name
  end

  def find_packages_by_nvre name, version, release, epoch
    Pulp::Repository.packages_by_nvre self.pulp_id, name, version, release, epoch
  end

  def find_latest_packages_by_name name
    Katello::PackageUtils.find_latest_packages(Pulp::Repository.packages_by_name(self.pulp_id, name))
  end

  def has_erratum? id
    self.errata.each {|err|
      return true if err.id == id
    }
    return false
  end

  def sync 
    [Pulp::Repository.sync(self.pulp_id)]
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
    Pulp::Repository.add_packages self.pulp_id,  pkg_id_list
  end

  def add_errata errata_id_list
    Pulp::Repository.add_errata self.pulp_id,  errata_id_list
  end

  def add_distribution distribution_id
    Pulp::Repository.add_distribution self.pulp_id,  distribution_id
  end

  def cancel_sync
    Rails.logger.info "Cancelling synchronization of repository #{self.pulp_id}"
    history = self.sync_status
    return if history.nil? || history.state == ::PulpSyncStatus::Status::NOT_SYNCED

    Pulp::Repository.cancel(self.pulp_id, history.uuid)
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
    sync_statuses.first
  end
    
  def sync_statuses
    @sync_status = self._get_most_recent_sync_status() if @sync_status.nil?
    @sync_status
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
    (get_groupid_param 'org').to_i
  end

  def environment_id
    (get_groupid_param 'env').to_i
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

  def content
    if not self.content_id.nil?
      Glue::Candlepin::Content.new(::Candlepin::Content.get(self.content_id))
    end
  end

  def self.repo_id product_name, repo_name, env_name, organization_name
    [organization_name, env_name, product_name, repo_name].compact.join("-").gsub(/[^-\w]/,"_")
  end

  def add_filters filter_ids
    ::Pulp::Repository.add_filters self.pulp_id, filter_ids
  end

  def remove_filters filter_ids
    ::Pulp::Repository.remove_filters self.pulp_id, filter_ids
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

  protected

  def content_for_clone
    return self.content unless self.content_id.nil?
    return self.clone_content unless self.clone_ids.empty?

    new_repo_path = Glue::Pulp::Repos.clone_repo_path_for_cp(self)
    new_content = self.create_content(new_repo_path)

    self.product.add_content new_content
    new_content.content
  end


  def clone_content
    return nil if self.clone_ids.empty?
    clone = Repository.find_by_pulp_id(self.clone_ids[0])
    clone.content
  end

  def create_content path
    new_content = Glue::Candlepin::ProductContent.new({
      :content => {
        :name => self.name,
        :contentUrl => path,
        :gpgUrl => "",
        :type => "yum",
        :label => self.name,
        :vendor => self.product.provider.provider_type
      },
      :enabled => true
    })
    new_content.create
    new_content
  end

  def _get_most_recent_sync_status()
    begin
      history = [Pulp::Repository.sync_status(pulp_id)]
    rescue
      history = Pulp::Repository.sync_history(pulp_id) 
    end
    return [::PulpSyncStatus.new(:state => ::PulpSyncStatus::Status::NOT_SYNCED)] if (history.nil? or history.empty?)
    history.collect{|item| ::PulpSyncStatus.using_pulp_task(item)}
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
