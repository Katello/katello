
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

class System < ActiveRecord::Base
  include Hooks
  define_hooks :add_system_group_hook, :remove_system_group_hook

  include Glue::Candlepin::Consumer if Katello.config.use_cp
  include Glue::Pulp::Consumer if Katello.config.use_pulp
  include Glue if Katello.config.use_cp ||  Katello.config.use_pulp
  include Glue::ElasticSearch::System if Katello.config.use_elasticsearch
  include Authorization::System
  include AsyncOrchestration

  after_rollback :rollback_on_create, :on => :create

  acts_as_reportable

  belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :systems
  belongs_to :system_template

  has_many :task_statuses, :as => :task_owner, :dependent => :destroy
  has_many :system_activation_keys, :dependent => :destroy
  has_many :activation_keys, :through => :system_activation_keys
  has_many :system_system_groups, :dependent => :destroy
  has_many :system_groups, {:through      => :system_system_groups,
                            :after_add    => :add_system_group,
                            :after_remove => :remove_system_group
                           }
  has_many :custom_info, :as => :informable, :dependent => :destroy
  belongs_to :content_view

  validates :environment, :presence => true
  validates_with Validators::NonLibraryEnvironmentValidator, :attributes => :environment
  # multiple systems with a single name are supported
  validates :name, :presence => true
  validates_with Validators::NoTrailingSpaceValidator, :attributes => :name
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates_length_of :location, :maximum => 255
  validates_with Validators::ContentViewEnvironmentValidator

  before_create  :fill_defaults

  after_create :init_default_custom_info_keys

  scope :by_env, lambda { |env| where('environment_id = ?', env) unless env.nil?}
  scope :completer_scope, lambda { |options| readable(options[:organization_id])}

  def add_system_group(system_group)
    run_hook(:add_system_group_hook, system_group)
  end

  def remove_system_group(system_group)
    run_hook(:remove_system_group_hook, system_group)
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
    if match_system
      pools = self.available_pools
    else
      pools = self.all_available_pools
    end

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

  def as_json(options)
    json = super(options)
    json['environment'] = environment.as_json unless environment.nil?
    json['activation_key'] = activation_keys.as_json unless activation_keys.nil?
    json['template'] = system_template.as_json unless system_template.nil?

    json['content_view'] = content_view.as_json if content_view
    json['ipv4_address'] = facts.try(:[], 'network.ipv4_address') if respond_to?(:facts)
    if respond_to?(:guest)
      if self.guest == 'true'
        json['host'] = self.host.attributes if self.host
      else

        json['guests'] = self.guests.map(&:attributes)
      end
    end
    json
  end

  def init_default_custom_info_keys
    self.organization.system_info_keys.each do |k|
      self.custom_info.create!(:keyname => k)
    end
  end

  def tasks
    TaskStatus.refresh_for_system(self)
  end

  # A rollback occurred while attempting to create the system; therefore, perform necessary cleanup.
  def rollback_on_create
    # remove the system from elasticsearch
    system_id = "id:#{self.id}"
    Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_system/_query?q=#{system_id}"
    Tire.index('katello_system').refresh
  end

  private
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
