
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

class NonLibraryEnvironmentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value
    record.errors[attribute] << N_("Cannot register a system to the '%s' environment") % "Library" if record.environment != nil && record.environment.library?
  end
end

class System < ActiveRecord::Base
  include Glue::Candlepin::Consumer
  include Glue::Pulp::Consumer if AppConfig.katello?
  include Glue
  include Authorization
  include AsyncOrchestration
  include IndexedModel

  after_rollback :rollback_on_create, :on => :create

  index_options :extended_json=>:extended_index_attrs,
                :json=>{:only=> [:name, :description, :id, :uuid, :created_at, :lastCheckin, :environment_id, :memory, :sockets]},
                :display_attrs => [:name,
                                   :description,
                                   :id,
                                   :uuid,
                                   :created_at,
                                   :lastCheckin,
                                   :system_group,
                                   :installed_products,
                                   "custom_info.KEYNAME",
                                   :memory,
                                   :sockets]

  dynamic_templates = [
      {
        "fact_string" => {
          :path_match => "facts.*",
          :mapping => {
              :type => "string",
              :analyzer => "kt_name_analyzer"
          }
        }
      },
      {
        "custom_info_string" => {
          :path_match => "custom_info.*",
          :mapping => {
              :type => "string",
              :analyzer => "kt_name_analyzer"
          }
        }
      }
  ]

  mapping   :dynamic_templates => dynamic_templates do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
    indexes :lastCheckin, :type=>'date'
    indexes :name_autocomplete, :type=>'string', :analyzer=>'autcomplete_name_analyzer'
    indexes :installed_products, :type=>'string', :analyzer=>:kt_name_analyzer
    indexes :memory, :type => 'integer'
    indexes :sockets, :type => 'integer'
    indexes :facts, :path=>"just_name" do
    end
    indexes :custom_info, :path => "just_name" do
    end

  end

  update_related_indexes :system_groups, :name

  acts_as_reportable

  belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :systems
  belongs_to :system_template

  has_many :task_statuses, :as => :task_owner, :dependent => :destroy

  has_many :system_activation_keys, :dependent => :destroy
  has_many :activation_keys, :through => :system_activation_keys

  has_many :system_system_groups, :dependent => :destroy
  has_many :system_groups, {:through => :system_system_groups, :before_add => :add_pulp_consumer_group, :before_remove => :remove_pulp_consumer_group}.merge(update_association_indexes)

  has_many :custom_info, :as => :informable, :dependent => :destroy

  validates :environment, :presence => true, :non_library_environment => true
  # multiple systems with a single name are supported
  validates :name, :presence => true, :no_trailing_space => true
  validates :description, :katello_description_format => true
  validates_length_of :location, :maximum => 255
  validates :sockets, :numericality => { :only_integer => true, :greater_than => 0 },
            :allow_nil => true, :if => ("validation_context == :create || validation_context == :update")
  validates :memory, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 },
            :allow_nil => true, :if => ("validation_context == :create || validation_context == :update")
  before_create  :fill_defaults

  after_create :init_default_custom_info_keys

  scope :by_env, lambda { |env| where('environment_id = ?', env) unless env.nil?}
  scope :completer_scope, lambda { |options| readable(options[:organization_id])}

  class << self
    def architectures
      { 'i386' => 'x86', 'ia64' => 'Itanium', 'x86_64' => 'x86_64', 'ppc' => 'PowerPC',
      's390' => 'IBM S/390', 's390x' => 'IBM System z', 'sparc64' => 'SPARC Solaris',
      'i686' => 'i686'}
    end

    def virtualized
      { "physical" => N_("Physical"), "virtualized" => N_("Virtual") }
    end
  end

  def organization
    environment.organization
  end

  def consumed_pool_ids
    self.pools.collect {|t| t['id']}
  end

  def available_releases
    self.environment.available_releases
  end

  def consumed_pool_ids=attributes
    attribs_to_unsub = consumed_pool_ids - attributes
    attribs_to_unsub.each do |id|
      self.unsubscribe id
    end

    attribs_to_sub = attributes - consumed_pool_ids
    attribs_to_sub.each do |id|
      self.subscribe id
    end
  end

  def filtered_pools match_system, match_installed, no_overlap
    pools = self.available_pools

    # Only available pool's with a product on the system'
    if match_installed
      pools = pools.select do |pool|
        self.installedProducts.any? do |installedProduct|
          pool['providedProducts'].any? do |providedProduct|
            installedProduct['productId'] == providedProduct['productId']
          end
        end
      end
    end

    # None of the available pool's products overlap a consumed pool's products
    if no_overlap
      pools = pools.select do |pool|
        pool['providedProducts'].all? do |providedProduct|
          self.consumed_entitlements.all? do |consumedEntitlement|
            consumedEntitlement.providedProducts.all? do |consumedProduct|
              consumedProduct.cp_id != providedProduct['productId']
            end
          end
        end
      end
    end

    return pools
  end

  def install_packages packages
    pulp_task = self.install_package(packages)
    task_status = save_task_status(pulp_task, :package_install, :packages, packages)
  end

  def uninstall_packages packages
    pulp_task = self.uninstall_package(packages)
    task_status = save_task_status(pulp_task, :package_remove, :packages, packages)
  end

  def update_packages packages=nil
    # if no packages are provided, a full system update will be performed (e.g ''yum update' equivalent)
    pulp_task = self.update_package(packages)
    task_status = save_task_status(pulp_task, :package_update, :packages, packages)
  end

  def install_package_groups groups
    pulp_task = self.install_package_group(groups)
    task_status = save_task_status(pulp_task, :package_group_install, :groups, groups)
  end

  def uninstall_package_groups groups
    pulp_task = self.uninstall_package_group(groups)
    task_status = save_task_status(pulp_task, :package_group_remove, :groups, groups)
  end

  def install_errata errata_ids
    pulp_task = self.install_consumer_errata(errata_ids)
    task_status = save_task_status(pulp_task, :errata_install, :errata_ids, errata_ids)
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def as_json(options)
    json = super(options)
    json['environment'] = environment.as_json unless environment.nil?
    json['activation_key'] = activation_keys.as_json unless activation_keys.nil?
    json['template'] = system_template.as_json unless system_template.nil?
    json['ipv4_address'] = facts.try(:[], 'network.ipv4_address')
    if self.guest == 'true'
      json['host'] = self.host.attributes if self.host
    else
      json['guests'] = self.guests.map(&:attributes)
    end
    json
  end

  def init_default_custom_info_keys
    self.organization.system_info_keys.each do |k|
      self.custom_info.create!(:keyname => k)
    end
  end

  def self.any_readable? org
    org.systems_readable? ||
        KTEnvironment.systems_readable(org).count > 0 ||
        SystemGroup.systems_readable(org).count > 0
  end

  def self.readable org
      raise "scope requires an organization" if org.nil?
      if org.systems_readable?
         where(:environment_id => org.environment_ids) #list all systems in an org
      else #just list for environments the user can access
        where_clause = "systems.environment_id in (#{KTEnvironment.systems_readable(org).select(:id).to_sql})"
        where_clause += " or "
        where_clause += "system_system_groups.system_group_id in (#{SystemGroup.systems_readable(org).select(:id).to_sql})"
        joins("left outer join system_system_groups on systems.id =
                                    system_system_groups.system_id").where(where_clause)
      end
  end

  def readable?
    sg_readable = false
    if AppConfig.katello?
      sg_readable = !SystemGroup.systems_readable(self.organization).where(:id=>self.system_group_ids).empty?
    end
    environment.systems_readable? || sg_readable
  end

  def editable?
    sg_editable = false
    if AppConfig.katello?
      sg_editable = !SystemGroup.systems_editable(self.organization).where(:id=>self.system_group_ids).empty?
    end
    environment.systems_editable? || sg_editable
  end

  def deletable?
    sg_deletable = false
    if AppConfig.katello?
      sg_deletable = !SystemGroup.systems_deletable(self.organization).where(:id=>self.system_group_ids).empty?
    end
    environment.systems_deletable? || sg_deletable
  end

  #TODO these two functions are somewhat poorly written and need to be redone
  def self.any_deletable? env, org
    if env
      env.systems_deletable? || org.system_groups.any?{|g| g.systems_deletable?}
    else
      org.systems_deletable? || org.system_groups.any?{|g| g.systems_deletable?}
    end
  end

  def self.registerable? env, org
    if env
      env.systems_registerable?
    else
      org.systems_registerable?
    end
  end

  def tasks
    TaskStatus.refresh_for_system(self)
  end

  def extended_index_attrs
    {:facts=>self.facts, :organization_id=>self.organization.id,
     :name_sort=>name.downcase, :name_autocomplete=>self.name,
     :system_group=>self.system_groups.collect{|g| g.name},
     :system_group_ids=>self.system_group_ids,
     :installed_products=>collect_installed_product_names,
     :sockets => self.sockets,
     :custom_info=>collect_custom_info
    }
  end

  # A rollback occurred while attempting to create the system; therefore, perform necessary cleanup.
  def rollback_on_create
    # remove the system from elasticsearch
    system_id = "id:#{self.id}"
    Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_system/_query?q=#{system_id}"
    Tire.index('katello_system').refresh
  end

  private
    def add_pulp_consumer_group record
      record.add_consumers([self.uuid])
    end

    def remove_pulp_consumer_group record
      record.del_consumers([self.uuid])
    end

    def save_task_status pulp_task, task_type, parameters_type, parameters
      TaskStatus.make(self, pulp_task, task_type, parameters_type => parameters)
    end

    def fill_defaults
      self.description = _("Initial Registration Params") unless self.description
      self.location = _("None") unless self.location
    end

    def collect_installed_product_names
      self.installedProducts ? self.installedProducts.map{ |p| p[:productName] } : []
    end

    def collect_custom_info
      hash = {}
      self.custom_info.each{ |c| hash[c.keyname] = c.value} if self.custom_info
      hash
    end

end
