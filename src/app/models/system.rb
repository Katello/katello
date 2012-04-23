
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
    record.errors[attribute] << N_("Cannot register a system with 'Library' environment ") if record.environment != nil && record.environment.library?
  end
end

class System < ActiveRecord::Base
  include Glue::Candlepin::Consumer
  include Glue::Pulp::Consumer if AppConfig.katello?
  include Glue
  include Authorization
  include AsyncOrchestration
  include IndexedModel

  
  index_options :extended_json=>:extended_index_attrs,
                :json=>{:only=> [:name, :description, :id, :uuid, :created_at, :lastCheckin, :environment_id]},
                :display_attrs=>[:name, :description, :id, :uuid, :created_at, :lastCheckin]

  mapping   :dynamic_templates =>[{"fact_string" => {
                          :path_match => "facts.*",
                          :mapping => {
                              :type=>"string",
                              :analyzer=>"kt_name_analyzer"
                          }
                        }} ] do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
    indexes :lastCheckin, :type=>'date'

    indexes :facts, :path=>"just_name" do
    end

  end

  acts_as_reportable

  belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :systems
  belongs_to :system_template

  has_many :system_tasks, :dependent => :destroy

  has_many :system_activation_keys, :dependent => :destroy
  has_many :activation_keys, :through => :system_activation_keys

  validates :environment, :presence => true, :non_library_environment => true
  validates :name, :presence => true, :no_trailing_space => true
  validates_uniqueness_of :name, :scope => :environment_id
  validates :description, :katello_description_format => true
  validates_length_of :location, :maximum => 255
  before_create  :fill_defaults

  scope :by_env, lambda { |env| where('environment_id = ?', env) unless env.nil?}
  scope :completer_scope, lambda { |options| readable(options[:organization_id])}

  
  class << self
    def architectures
      { 'i386' => 'x86', 'ia64' => 'Itanium', 'x86_64' => 'x86_64', 'ppc' => 'PowerPC',
      's390' => 'IBM S/390', 's390x' => 'IBM System z', 'sparc64' => 'SPARC Solaris' }
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

  def install_packages packages
    pulp_task = self.install_package(packages)
    system_task = save_system_task(pulp_task, :package_install, :packages, packages)
  end

  def uninstall_packages packages
    pulp_task = self.uninstall_package(packages)
    system_task = save_system_task(pulp_task, :package_remove, :packages, packages)
  end

  def update_packages packages=nil
    # if no packages are provided, a full system update will be performed (e.g ''yum update' equivalent)
    pulp_task = self.update_package(packages)
    system_task = save_system_task(pulp_task, :package_update, :packages, packages)
  end

  def install_package_groups groups
    pulp_task = self.install_package_group(groups)
    system_task = save_system_task(pulp_task, :package_group_install, :groups, groups)
  end

  def uninstall_package_groups groups
    pulp_task = self.uninstall_package_group(groups)
    system_task = save_system_task(pulp_task, :package_group_remove, :groups, groups)
  end

  def install_errata errata_ids
    pulp_task = self.install_consumer_errata(errata_ids)
    system_task = save_system_task(pulp_task, :errata_install, :errata_ids, errata_ids)
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

  def self.any_readable? org
    org.systems_readable? ||
        User.allowed_to?(KTEnvironment::SYSTEMS_READABLE, :environments, org.environment_ids, org, true)
  end

  def self.readable org
      raise "scope requires an organization" if org.nil?
      if org.systems_readable?
         where(:environment_id => org.environment_ids) #list all systems in an org 
      else #just list for environments the user can access
        where("systems.environment_id in (#{User.allowed_tags_sql(KTEnvironment::SYSTEMS_READABLE, :environments, org)})")
      end    
  end

  def readable?
    environment.systems_readable?
  end

  def editable?
    environment.systems_editable?
  end

  def deletable?
    environment.systems_deletable?
  end

  def self.deletable? env, org
    org ||= env.organization if env
    ret = false
    ret ||= User.allowed_to?([:delete_systems], :organizations, nil, org) if org
    ret ||= User.allowed_to?([:delete_systems], :environments, env.id, org) if env
    ret
  end

  def self.registerable? env, org
    org ||= env.organization if env
    ret = false
    ret ||= User.allowed_to?([:register_systems], :organizations, nil, org) if org
    ret ||= User.allowed_to?([:register_systems], :environments, env.id, org) if env
    ret
  end

  def tasks
    SystemTask.refresh_for_system(self)
  end



  def extended_index_attrs
    {:facts=>self.facts, :organization_id=>self.organization.id, :name_sort=>name.downcase}
  end


  private
    def save_system_task pulp_task, task_type, parameters_type, parameters
      SystemTask.make(self, pulp_task, task_type, parameters_type => parameters)
    end

    def fill_defaults
      self.description = _("Initial Registration Params") unless self.description
      self.location = _("None") unless self.location
    end

end
