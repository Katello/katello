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

class SystemGroup < ActiveRecord::Base

  include Glue::Pulp::ConsumerGroup if (Katello.config.use_pulp)
  include Glue
  include Ext::Authorization
  include Ext::IndexedModel
  include Ext::PermissionTagCleanup

  index_options :extended_json=>:extended_index_attrs,
                :json=>{:only=>[:id, :organization_id, :name, :description, :max_systems]},
                :display_attrs=>[:name, :description, :system]

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
    indexes :name_autocomplete, :type=>'string', :analyzer=>'autcomplete_name_analyzer'
  end

  update_related_indexes :systems, :name

  has_many :key_system_groups, :dependent => :destroy
  has_many :activation_keys, :through => :key_system_groups

  has_many :system_system_groups, :dependent => :destroy
  has_many :systems, {:through => :system_system_groups, :before_add => :add_pulp_consumer_group,
           :before_remove => :remove_pulp_consumer_group}.merge(update_association_indexes)

  has_many :jobs, :as => :job_owner

  # we use db_environments to host the data, but all input, output
  #  should go through 'environments' accessor and getter (defined below)
  #  db_environment(id)s accessors are marked private to help stop usage
  #  we do this as we need to maintain the integrity of systems
  #  and environments associated with a group, and none of the other solutions
  #  allow us to do this.
  has_many :environment_system_groups, :dependent =>:destroy
  has_many :db_environments, {:through=>:environment_system_groups, :source=>:environment,
                    :class_name => 'KTEnvironment', :foreign_key=>:environment_id}
  before_save :save_system_environments

  validates :pulp_id, :presence => true
  validates :name, :presence => true
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_presence_of :organization_id, :message => N_("Organization cannot be blank.")
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("must be unique within one organization")
  validates_uniqueness_of :pulp_id, :message=> N_("must be unique.")
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description

  alias_attribute :system_limit, :max_systems
  UNLIMITED_SYSTEMS = -1
  validates_numericality_of :system_limit, :only_integer => true, :greater_than_or_equal_to => -1, :message => N_("must be a positive integer value.")
  validate :validate_max_systems

  def validate_max_systems
    if new_record? or max_systems_changed?
      if (max_systems != UNLIMITED_SYSTEMS) and (systems.length > 0 and (systems.length > max_systems))
        errors.add :system_limit, _("may not be less than the number of systems associated with the system group.")
      elsif (max_systems == 0)
        errors.add :system_limit, _("may not be set to 0.")
      end
    end
  end

  belongs_to :organization

  before_validation(:on=>:create) do
    self.pulp_id ||= "#{self.organization.label}-#{self.name}-#{SecureRandom.hex(4)}"
  end

  default_scope :order => 'name ASC'

  scope :readable, lambda { |org|
    items(org, READ_PERM_VERBS)
  }
  scope :editable, lambda { |org|
    items(org, [:update])
  }
  scope :systems_readable, lambda{|org|
      SystemGroup.items(org, SYSTEM_READ_PERMS)
  }

  scope :systems_editable, lambda{|org|
      SystemGroup.items(org, [:update_systems])
  }

  scope :systems_deletable, lambda{|org|
      SystemGroup.items(org, [:delete_systems])
  }

  def self.creatable? org
    User.allowed_to?([:create], :system_groups, nil, org)
  end

  def self.any_readable? org
    User.allowed_to?(READ_PERM_VERBS, :system_groups, nil, org)
  end

  def systems_readable?
    User.allowed_to?(SYSTEM_READ_PERMS, :system_groups, self.id, self.organization)
  end

  def systems_deletable?
    User.allowed_to?([:delete_systems], :system_groups, self.id, self.organization)
  end

  def systems_editable?
    User.allowed_to?([:update_systems], :system_groups, self.id, self.organization)
  end

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :system_groups, self.id, self.organization)
  end

  def editable?
    User.allowed_to?([:update, :create], :system_groups, self.id, self.organization)
  end

  def deletable?
    User.allowed_to?([:delete, :create], :system_groups, self.id, self.organization)
  end

  def self.list_tags org_id
    SystemGroup.select('id,name').where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.tags(ids)
    select('id,name').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.list_verbs  global = false
    {
       :create => _("Administer System Groups"),
       :read => _("Read System Group"),
       :update => _("Modify System Group details and system membership"),
       :delete => _("Delete System Group"),
       :read_systems => _("Read Systems in System Group"),
       :update_systems => _("Modify Systems in System Group"),
       :delete_systems => _("Delete Systems in System Group")
    }.with_indifferent_access
  end

  def self.read_verbs
    [:read]
  end

  def self.no_tag_verbs
    [:create]
  end

  def install_packages packages
    raise Errors::SystemGroupEmptyException if self.systems.empty?
    pulp_job = self.install_package(packages)
    job = save_job(pulp_job, :package_install, :packages, packages)
  end

  def uninstall_packages packages
    raise Errors::SystemGroupEmptyException if self.systems.empty?
    pulp_job = self.uninstall_package(packages)
    job = save_job(pulp_job, :package_remove, :packages, packages)
  end

  def update_packages packages=nil
    # if no packages are provided, a full system update will be performed (e.g ''yum update' equivalent)
    raise Errors::SystemGroupEmptyException if self.systems.empty?
    pulp_job = self.update_package(packages)
    job = save_job(pulp_job, :package_update, :packages, packages)
  end

  def install_package_groups groups
    raise Errors::SystemGroupEmptyException if self.systems.empty?
    pulp_job = self.install_package_group(groups)
    job = save_job(pulp_job, :package_group_install, :groups, groups)
  end

  def update_package_groups(groups)
    raise Errors::SystemGroupEmptyException if self.systems.empty?
    pulp_job = self.install_package_group(groups)
    job = save_job(pulp_job, :package_group_update, :groups, groups)
  end

  def uninstall_package_groups groups
    raise Errors::SystemGroupEmptyException if self.systems.empty?
    pulp_job = self.uninstall_package_group(groups)
    job = save_job(pulp_job, :package_group_remove, :groups, groups)
  end

  def install_errata errata_ids
    raise Errors::SystemGroupEmptyException if self.systems.empty?
    pulp_job = self.install_consumer_errata(errata_ids)
    job = save_job(pulp_job, :errata_install, :errata_ids, errata_ids)
  end

  def refreshed_jobs
    Job.refresh_for_owner(self)
  end

  def extended_index_attrs
    {:name_sort=>name.downcase, :name_autocomplete=>self.name,
     :system=>self.systems.collect{|s| s.name}
    }
  end

  def environments
    @cached_environments ||= db_environments.all #.all to ensure we don't refer to the AR relation
  end

  def environments=(values)
    @cached_environments = values
  end

  def environment_key_conflicts
    if self.environments.empty?
      []
    else
      self.activation_keys.select{|k| !self.environments.include?(k.environment)}
    end
  end

  def total_systems
    systems.length
  end

  # Retrieve the list of accessible system groups in the organization specified, returning
  # them in the following arrays:
  #   critical: those groups that have 1 or more security errata that need to be applied
  #   warning: those groups that have 1 or more non-security errata that need to be applied
  #   ok: those groups that are completely up to date
  def self.lists_by_updates_needed(organization)
    groups_hash = {}
    groups = SystemGroup.readable(organization)

    # determine the state (critical/warning/ok) for each system group
    groups.each do |group|
      group_state = :ok

      group.systems.each do |system|
        system.errata.each do |erratum|
          case erratum.type
            when Glue::Pulp::Errata::SECURITY
              # there is a critical errata, so stop searching...
              group_state = :critical
              break

            when Glue::Pulp::Errata::BUGZILLA
            when Glue::Pulp::Errata::ENHANCEMENT
              # set state to warning, but continue searching...
              group_state = :warning
          end
        end
        break if group_state == :critical
      end

      groups_hash[group_state] ||= []
      groups_hash[group_state] << group
    end
    return groups_hash[:critical].to_a, groups_hash[:warning].to_a, groups_hash[:ok].to_a
  end

  private

  #make hidden db_environments accessors private to discourage use
  SystemGroup.send(:private, :db_environments)
  SystemGroup.send(:private, :db_environment_ids)

  def save_system_environments
    if @cached_environments #there was an env modification
      if !@cached_environments.empty?
        #verify that systems match modified environments
        sys_envs = self.systems.collect{|s| s.environment_id}.uniq
        group_envs = @cached_environments.collect{|e| e.id}
        if (sys_envs  - group_envs).length > 0
          raise _("Could not modify environments. System group membership does not match new environment association.")
        end

        #verify that keys match modified environments
        keys = self.environment_key_conflicts
        if !keys.empty?
          raise _("Could not modify environments.  One or more associated activation keys (%s) would become invalid.") % keys.collect{|k| k.name}.join(',')
        end
      end
      self.db_environments = self.environments
    end
  end

  def add_pulp_consumer_group record
    self.add_consumers([record.uuid])
  end

  def remove_pulp_consumer_group record
    self.del_consumers([record.uuid])
  end

  def save_job pulp_job, job_type, parameters_type, parameters
    job = Job.create!(:pulp_id => pulp_job[:id], :job_owner => self)
    job.create_tasks(self, pulp_job[:tasks], job_type, parameters_type => parameters)
    job
  end

  def self.items org, verbs
    raise "scope requires an organization" if org.nil?
    resource = :system_groups
    if User.allowed_all_tags?(verbs, resource, org)
       where(:organization_id => org)
    else
      where("system_groups.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
    end
  end

  READ_PERM_VERBS = SystemGroup.list_verbs.keys
  SYSTEM_READ_PERMS = [:read_systems, :update_systems, :delete_systems]

end
