#
# Copyright 2013 Red Hat, Inc.
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
class SystemGroup < ActiveRecord::Base
  self.include_root_in_json = false

  include Hooks
  define_hooks :add_system_hook, :remove_system_hook

  include Authorization::SystemGroup
  include Glue::ElasticSearch::SystemGroup if Katello.config.use_elasticsearch

  include Authorization::SystemGroup
  include Ext::PermissionTagCleanup

  has_many :key_system_groups, :dependent => :destroy
  has_many :activation_keys, :through => :key_system_groups

  has_many :system_system_groups, :dependent => :destroy
  has_many :systems, {:through      => :system_system_groups,
                      :after_add    => :add_system,
                      :after_remove => :remove_system
                     }

  has_many :jobs, :as => :job_owner, :dependent => :nullify

  validates :name, :presence => true
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates :organization_id, :presence => {:message => N_("Organization cannot be blank.")}
  validates :name, :uniqueness => {:scope => :organization_id, :message => N_("must be unique within one organization")}
  validates :system_limit, :numericality => {:only_integer => true,
                                             :greater_than_or_equal_to => -1,
                                             :less_than_or_equal_to => 2_147_483_647,
                                             :message => N_("must be a positive integer value.")}

  alias_attribute :system_limit, :max_systems
  UNLIMITED_SYSTEMS = -1
  validate :validate_max_systems

  def validate_max_systems
    if new_record? || max_systems_changed?
      if (max_systems != UNLIMITED_SYSTEMS) && (systems.length > 0 && (systems.length > max_systems))
        errors.add :system_limit, _("may not be less than the number of systems associated with the system group.")
      elsif (max_systems == 0)
        errors.add :system_limit, _("may not be set to 0.")
      end
    end
  end

  belongs_to :organization, :inverse_of => :system_groups

  def add_system(system)
    run_hook(:add_system_hook, system)
  end

  def remove_system(system)
    run_hook(:remove_system_hook, system)
  end

  def install_packages(packages)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_group_action do |consumer_group|
      pulp_job = consumer_group.install_package(packages)
      save_job(pulp_job, :package_install, :packages, packages)
    end
  end

  def uninstall_packages(packages)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_group_action do |consumer_group|
      pulp_job = consumer_group.uninstall_package(packages)
      save_job(pulp_job, :package_remove, :packages, packages)
    end
  end

  def update_packages(packages = nil)
    # if no packages are provided, a full system update will be performed (e.g ''yum update' equivalent)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_group_action do |consumer_group|
      pulp_job = consumer_group.update_package(packages)
      save_job(pulp_job, :package_update, :packages, packages)
    end
  end

  def install_package_groups(groups)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_group_action do |consumer_group|
      pulp_job = consumer_group.install_package_group(groups)
      save_job(pulp_job, :package_group_install, :groups, groups)
    end
  end

  def update_package_groups(groups)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_group_action do |consumer_group|
      pulp_job = consumer_group.install_package_group(groups)
      save_job(pulp_job, :package_group_update, :groups, groups)
    end
  end

  def uninstall_package_groups(groups)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_group_action do |consumer_group|
      pulp_job = consumer_group.uninstall_package_group(groups)
      save_job(pulp_job, :package_group_remove, :groups, groups)
    end
  end

  def install_errata(errata_ids)
    fail Errors::SystemGroupEmptyException if self.systems.empty?
    perform_group_action do |consumer_group|
      pulp_job = consumer_group.install_consumer_errata(groups)
      save_job(pulp_job, :errata_install, :errata_ids, errata_ids)
    end
  end

  def refreshed_jobs
    Job.refresh_for_owner(self)
  end

  def consumer_ids
    self.systems.pluck(:uuid)
  end

  def errata(type = nil)
    ::Errata.applicable_for_consumers(consumer_ids, type)
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
      unless group.systems.empty?
        group.errata.each do |erratum|
          case erratum.type
          when Errata::SECURITY
            # there is a critical errata, so stop searching...
            group_state = :critical
            break

          when Errata::BUGZILLA
          when Errata::ENHANCEMENT
            # set state to warning, but continue searching...
            group_state = :warning
          end

        end
      end

      groups_hash[group_state] ||= []
      groups_hash[group_state] << group
    end
    return groups_hash[:critical].to_a, groups_hash[:warning].to_a, groups_hash[:ok].to_a
  end

  private

  def perform_group_action
    group = Glue::Pulp::ConsumerGroup.new
    group.pulp_id = ::UUIDTools::UUID.random_create.to_s
    group.consumer_ids = consumer_ids
    group.set_pulp_consumer_group
    yield(group)
  ensure
    group.del_pulp_consumer_group
  end

  def save_job(pulp_job, job_type, parameters_type, parameters)
    job = Job.create!(:pulp_id => pulp_job.first[:task_group_id], :job_owner => self)
    job.create_tasks(self, pulp_job, job_type, parameters_type => parameters)
    job
  end

end
end
