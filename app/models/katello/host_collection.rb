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
  class HostCollection < Katello::Model
    self.include_root_in_json = false

    include Hooks
    define_hooks :add_system_hook, :remove_system_hook

    include Katello::Authorization::HostCollection
    include Glue::ElasticSearch::HostCollection if Katello.config.use_elasticsearch

    has_many :key_host_collections, :class_name => "Katello::KeyHostCollection", :dependent => :destroy
    has_many :activation_keys, :through => :key_host_collections

    has_many :system_host_collections, :class_name => "Katello::SystemHostCollection", :dependent => :destroy
    has_many :systems, :through => :system_host_collections, :class_name => "Katello::System",
                       :after_add => :add_system, :after_remove => :remove_system

    has_many :jobs, :class_name => "Katello::Job", :as => :job_owner, :dependent => :nullify

    validates_lengths_from_database
    validates :name, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates :organization_id, :presence => {:message => N_("Organization cannot be blank.")}
    validates :name, :uniqueness => {:scope => :organization_id, :message => N_("must be unique within one organization")}
    validates :content_host_limit, :numericality => {:only_integer => true,
                                                     :allow_nil => true,
                                                     :greater_than_or_equal_to => 1,
                                                     :less_than_or_equal_to => 2_147_483_647,
                                                     :message => N_("must be a positive integer value.")}

    alias_attribute :content_host_limit, :max_content_hosts
    validate :validate_max_content_hosts

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true

    def validate_max_content_hosts
      if new_record? || max_content_hosts_changed?
        if (!unlimited_content_hosts) && (systems.length > 0 && (systems.length > max_content_hosts))
          errors.add :content_host_limit, _("may not be less than the number of content hosts associated with the host collection.")
        elsif (max_content_hosts == 0)
          errors.add :content_host_limit, _("may not be set to 0.")
        end
      end
    end

    belongs_to :organization, :inverse_of => :host_collections

    def add_system(system)
      run_hook(:add_system_hook, system)
    end

    def remove_system(system)
      run_hook(:remove_system_hook, system)
    end

    def install_packages(packages)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.install_package(packages)
        save_job(pulp_job, :package_install, :packages, packages)
      end
    end

    def uninstall_packages(packages)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.uninstall_package(packages)
        save_job(pulp_job, :package_remove, :packages, packages)
      end
    end

    def update_packages(packages = nil)
      # if no packages are provided, a full system update will be performed (e.g ''yum update' equivalent)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.update_package(packages)
        save_job(pulp_job, :package_update, :packages, packages)
      end
    end

    def install_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.install_package_group(groups)
        save_job(pulp_job, :package_group_install, :groups, groups)
      end
    end

    def update_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.install_package_group(groups)
        save_job(pulp_job, :package_group_update, :groups, groups)
      end
    end

    def uninstall_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.uninstall_package_group(groups)
        save_job(pulp_job, :package_group_remove, :groups, groups)
      end
    end

    def install_errata(errata_ids)
      fail Errors::HostCollectionEmptyException if self.systems.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.install_consumer_errata(errata_ids)
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
      query = Erratum.joins(:system_errata).where("#{SystemErratum.table_name}.system_id" => self.system_ids)
      type ? query.of_type(type) : query
    end

    def total_content_hosts
      systems.length
    end

    # Retrieve the list of accessible host collections in the organization specified, returning
    # them in the following arrays:
    #   critical: those collections that have 1 or more security errata that need to be applied
    #   warning: those collections that have 1 or more non-security errata that need to be applied
    #   ok: those collections that are completely up to date
    def self.lists_by_updates_needed(organization)
      host_collections_hash = {}
      host_collections = HostCollection.where(:organization_id => organization.id).readable

      # determine the state (critical/warning/ok) for each host collection
      host_collections.each do |host_collection|
        host_collection_state = :ok
        unless host_collection.systems.empty?
          host_collection.errata.each do |erratum|
            case erratum.errata_type
            when Erratum::SECURITY
              # there is a critical errata, so stop searching...
              host_collection_state = :critical
              break

            when Erratum::BUGZILLA
            when Erratum::ENHANCEMENT
              # set state to warning, but continue searching...
              host_collection_state = :warning
            end
          end
        end

        host_collections_hash[host_collection_state] ||= []
        host_collections_hash[host_collection_state] << host_collection
      end
      return host_collections_hash[:critical].to_a, host_collections_hash[:warning].to_a, host_collections_hash[:ok].to_a
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
      job.create_tasks(self.org, pulp_job, job_type, parameters_type => parameters)
      job
    end

    def self.humanize_class_name(_name = nil)
      _("Host Collections")
    end
  end
end
