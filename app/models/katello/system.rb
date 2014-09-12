
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

module Katello
class System < Katello::Model
  DEFAULT_CP_TYPE = Glue::Candlepin::Consumer::SYSTEM

  self.include_root_in_json = false

  include Hooks
  define_hooks :add_host_collection_hook, :remove_host_collection_hook,
               :add_activation_key_hook, :remove_activation_key_hook,
               :as_json_hook

  include ForemanTasks::Concerns::ActionSubject
  include Glue::Candlepin::Consumer if Katello.config.use_cp
  include Glue::Pulp::Consumer if Katello.config.use_pulp
  include Glue if Katello.config.use_cp || Katello.config.use_pulp
  include Glue::ElasticSearch::System if Katello.config.use_elasticsearch
  include Authorization::System

  audited :on => [:create], :allow_mass_assignment => true

  attr_accessible :name, :uuid, :description, :location, :environment, :content_view,
                  :environment_id, :content_view_id, :host_collection_ids, :host_id,
                  :activation_key_ids

  after_rollback :rollback_on_create, :on => :create

  belongs_to :environment, :class_name => "Katello::KTEnvironment", :inverse_of => :systems
  belongs_to :foreman_host, :class_name => "::Host", :foreign_key => :host_id, :inverse_of => :content_host

  has_many :task_statuses, :class_name => "Katello::TaskStatus", :as => :task_owner, :dependent => :destroy
  has_many :system_activation_keys, :class_name => "Katello::SystemActivationKey", :dependent => :destroy
  has_many :activation_keys, {
                               :through => :system_activation_keys,
                               :after_add    => :add_activation_key,
                               :after_remove => :remove_activation_key
                             }
  has_many :system_host_collections, :class_name => "Katello::SystemHostCollection", :dependent => :destroy
  has_many :host_collections, {:through      => :system_host_collections,
                               :after_add    => :add_host_collection,
                               :after_remove => :remove_host_collection
                              }
  has_many :custom_info, :class_name => "Katello::CustomInfo", :as => :informable, :dependent => :destroy
  has_many :audits, :class_name => "::Audit", :as => :auditable, :dependent => :destroy

  belongs_to :content_view, :inverse_of => :systems

  before_validation :set_default_content_view, :unless => :persisted?
  validates :environment, :presence => true
  validates :content_view, :presence => true, :allow_blank => false
  validates_with Validators::NoTrailingSpaceValidator, :attributes => :name
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates :location, :length => {:maximum => 255}
  validates_with Validators::ContentViewEnvironmentValidator
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name

  before_create  :fill_defaults
  after_create :init_default_custom_info

  before_update :update_foreman_host, :if => proc { |r| r.environment_id_changed? || r.content_view_id_changed? }

  scope :in_environment, lambda { |env| where('environment_id = ?', env) unless env.nil?}
  scope :completer_scope, lambda { |options| readable(options[:organization_id])}
  scope :by_uuids, lambda { |uuids| where(:uuid => uuids)}

  scoped_search :on => :name, :complete_value => true
  scoped_search :in => :environment, :on => :organization_id, :complete_value => true, :rename => :organization_id

  def self.in_organization(organization)
    where(:environment_id => organization.kt_environments.pluck(:id))
  end

  def self.uuids_to_ids(uuids)
    systems = by_uuids(uuids)
    ids_not_found = Set.new(uuids).subtract(systems.pluck(:uuid))
    fail Errors::NotFound.new(_("Systems [%s] not found.") % ids_not_found.to_a.join(',')) unless ids_not_found.blank?
    systems.pluck(:id)
  end

  def add_host_collection(host_collection)
    run_hook(:add_host_collection_hook, host_collection)
  end

  def remove_host_collection(host_collection)
    run_hook(:remove_host_collection_hook, host_collection)
  end

  def add_activation_key(activation_key)
    run_hook(:add_activation_key_hook, activation_key)
  end

  def remove_activation_key(activation_key)
    run_hook(:remove_activation_key_hook, activation_key)
  end

  def registered_by
    audits.first.try(:username) unless activation_keys.length > 0
  end

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
    self.content_view.version(self.environment).available_releases
  end

  def consumed_pool_ids=(attributes)
    attribs_to_unsub = consumed_pool_ids - attributes
    attribs_to_unsub.each do |id|
      self.unsubscribe id
    end

    attribs_to_sub = attributes - consumed_pool_ids
    attribs_to_sub.each do |id|
      self.subscribe id
    end
  end

  def filtered_pools(match_system, match_installed, no_overlap)
    if match_system
      pools = self.available_pools
    else
      pools = self.all_available_pools
    end

    # Only available pool's with a product on the system'
    if match_installed
      pools = pools.select do |pool|
        self.installedProducts.any? do |installed_product|
          pool['providedProducts'].any? do |provided_product|
            installed_product['productId'] == provided_product['productId']
          end
        end
      end
    end

    # None of the available pool's products overlap a consumed pool's products
    if no_overlap
      pools = pools.select do |pool|
        pool['providedProducts'].all? do |provided_product|
          self.consumed_entitlements.all? do |consumed_entitlement|
            consumed_entitlement.providedProducts.all? do |consumed_product|
              consumed_product.cp_id != provided_product['productId']
            end
          end
        end
      end
    end

    return pools
  end

  def install_packages(packages)
    pulp_task = self.install_package(packages)
    save_task_status(pulp_task, :package_install, :packages, packages)
  end

  def uninstall_packages(packages)
    pulp_task = self.uninstall_package(packages)
    save_task_status(pulp_task, :package_remove, :packages, packages)
  end

  def update_packages(packages = nil)
    # if no packages are provided, a full system update will be performed (e.g ''yum update' equivalent)
    pulp_task = self.update_package(packages)
    save_task_status(pulp_task, :package_update, :packages, packages)
  end

  def install_package_groups(groups)
    pulp_task = self.install_package_group(groups)
    save_task_status(pulp_task, :package_group_install, :groups, groups)
  end

  def uninstall_package_groups(groups)
    pulp_task = self.uninstall_package_group(groups)
    save_task_status(pulp_task, :package_group_remove, :groups, groups)
  end

  def install_errata(errata_ids)
    pulp_task = self.install_consumer_errata(errata_ids)
    save_task_status(pulp_task, :errata_install, :errata_ids, errata_ids)
  end

  def as_json(options)
    json = super(options)
    json['environment'] = environment.as_json unless environment.nil?
    json['activation_key'] = activation_keys.as_json unless activation_keys.nil?

    json['content_view'] = content_view.as_json if content_view
    json['ipv4_address'] = facts.try(:[], 'network.ipv4_address') if respond_to?(:facts)

    if respond_to?(:virtual_guest)
      if self.virtual_guest == 'true'
        json['virtual_host'] = self.virtual_host.attributes if self.virtual_host
      else
        json['virtual_guests'] = self.virtual_guests.map(&:attributes)
      end
    end

    if options[:expanded]
      json['editable'] = editable?
      json['type'] = type
    end

    run_hook(:as_json_hook, json)

    json
  end

  def system_type
    if respond_to?(:virtual_guest) && virtual_guest
      _("Virtual Guest")
    else
      case self
      when Hypervisor
        _("Hypervisor")
      else
        _("Host")
      end
    end
  end

  def init_default_custom_info
    self.organization.default_info_hash["system"].each do |k|
      self.custom_info.create!(:keyname => k)
    end
  end

  def refresh_tasks
    refresh_running_tasks
    import_candlepin_tasks
  end

  def tasks
    refresh_tasks
    self.task_statuses
  end

  # A rollback occurred while attempting to create the system; therefore, perform necessary cleanup.
  def rollback_on_create
    # remove the system from elasticsearch
    system_id = "id:#{self.id}"
    Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_system/_query?q=#{system_id}"
    Tire.index('katello_system').refresh
  end

  def reportable_data(options = {})
    hash = self.as_json(options.slice(:only, :except))
    if options[:methods]
      options[:methods].each{ |method| hash[method] = self.send(method) }
    end
    hash.with_indifferent_access
  end

  def self.available_locks
    [:read, :write]
  end

  def related_resources
    self.organization
  end

  def to_action_input
    super.merge(uuid: uuid)
  end

  private

  def refresh_running_tasks
    ids = self.task_statuses.where(:state => [:waiting, :running]).pluck(:id)
    TaskStatus.refresh(ids)
  end

  def save_task_status(pulp_task, task_type, parameters_type, parameters)
    TaskStatus.make(self, pulp_task, task_type, parameters_type => parameters)
  end

  def fill_defaults
    self.description = _("Initial Registration Params") unless self.description
    self.location = _("None") unless self.location
  end

  def set_default_content_view
    self.content_view = self.environment.try(:default_content_view) unless self.content_view
  end

  def update_foreman_host
    # If the lifecycle environment and/or content view are being changed for the content host
    # (system), then we may also need to update the associated foreman host's puppet environment
    if self.foreman_host &&
       self.foreman_host.environment.lifecycle_environment &&
       self.foreman_host.environment.content_view

      if puppet_env = self.content_view.puppet_env(self.environment).try(:puppet_environment)
        if puppet_env.id != self.foreman_host.environment_id
          self.foreman_host.environment_id = puppet_env.id
          self.foreman_host.save!
        end
      else
        fail Errors::NotFound,
             _("Couldn't find puppet environment associated with lifecycle environment '%{env}' and content view '%{view}'") %
                 { :env => self.environment.name, :view => self.content_view.name }
      end
    end
  end

  # rubocop:disable SymbolName
  def collect_installed_product_names
    self.installedProducts ? self.installedProducts.map { |p| p[:productName] } : []
  end

  def collect_custom_info
    hash = {}
    self.custom_info.each { |c| hash[c.keyname] = c.value } if self.custom_info
    hash
  end

  def self.humanize_class_name(name = nil)
    _('Content Host')
  end
end
end
