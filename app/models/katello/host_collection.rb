module Katello
  class HostCollection < Katello::Model
    self.include_root_in_json = false

    include Katello::Authorization::HostCollection

    has_many :key_host_collections, :class_name => "Katello::KeyHostCollection", :dependent => :destroy
    has_many :activation_keys, :through => :key_host_collections

    has_many :host_collection_hosts, :class_name => "Katello::HostCollectionHosts", :dependent => :destroy
    has_many :hosts, :through => :host_collection_hosts, :class_name => "::Host::Managed"

    has_many :jobs, :class_name => "Katello::Job", :as => :job_owner, :dependent => :nullify

    validates_lengths_from_database
    validates :name, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates :organization_id, :presence => {:message => N_("Organization cannot be blank.")}
    validates :name, :uniqueness => {:scope => :organization_id, :message => N_("must be unique within one organization")}
    validates :max_hosts, :numericality => {:only_integer => true,
                                            :allow_nil => true,
                                            :greater_than_or_equal_to => 1,
                                            :less_than_or_equal_to => 2_147_483_647,
                                            :message => N_("must be a positive integer value.")}
    validates :max_hosts, :presence => {:message => N_("max_hosts must be given a value if this host collection is not unlimited.")},
                                  :if => ->(host_collection) { !host_collection.unlimited_hosts }
    validate :max_hosts_check, :if => ->(host_collection) { host_collection.new_record? || host_collection.max_hosts_changed? }
    validate :max_hosts_not_exceeded, :on => :create

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true
    scoped_search :in => :hosts, :complete_value => false

    def max_hosts_check
      if !unlimited_hosts && (hosts.length > 0 && (hosts.length.to_i > max_hosts.to_i)) && max_hosts_changed?
        errors.add :max_host, N_("may not be less than the number of hosts associated with the host collection.")
      end
    end

    def max_hosts_not_exceeded
      if !unlimited_hosts && (hosts.size.to_i > max_hosts.to_i)
        errors.add :base,  N_("You cannot have more than #{max_hosts} host(s) associated with host collection #{name}." %
                              {:max_hosts => max_hosts, :name => name})
      end
    end

    belongs_to :organization, :inverse_of => :host_collections

    def install_packages(packages)
      fail Errors::HostCollectionEmptyException if self.hosts.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.install_package(packages)
        save_job(pulp_job, :package_install, :packages, packages)
      end
    end

    def uninstall_packages(packages)
      fail Errors::HostCollectionEmptyException if self.hosts.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.uninstall_package(packages)
        save_job(pulp_job, :package_remove, :packages, packages)
      end
    end

    def update_packages(packages = nil)
      # if no packages are provided, a full host update will be performed (e.g ''yum update' equivalent)
      fail Errors::HostCollectionEmptyException if self.hosts.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.update_package(packages)
        save_job(pulp_job, :package_update, :packages, packages)
      end
    end

    def install_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.hosts.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.install_package_group(groups)
        save_job(pulp_job, :package_group_install, :groups, groups)
      end
    end

    def update_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.hosts.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.install_package_group(groups)
        save_job(pulp_job, :package_group_update, :groups, groups)
      end
    end

    def uninstall_package_groups(groups)
      fail Errors::HostCollectionEmptyException if self.hosts.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.uninstall_package_group(groups)
        save_job(pulp_job, :package_group_remove, :groups, groups)
      end
    end

    def install_errata(errata_ids)
      fail Errors::HostCollectionEmptyException if self.hosts.empty?
      perform_group_action do |consumer_group|
        pulp_job = consumer_group.install_consumer_errata(errata_ids)
        save_job(pulp_job, :errata_install, :errata_ids, errata_ids)
      end
    end

    def refreshed_jobs
      Job.refresh_for_owner(self)
    end

    def consumer_ids
      consumer_ids = []

      self.hosts.each do |host|
        if host.content_facet
          consumer_ids.push(host.content_facet.uuid)
        end
      end

      consumer_ids
    end

    def errata(type = nil)
      query = Erratum.joins(:content_facet_errata).where("#{Katello::Host::ContentFacet.table_name}.host_id" => self.host_ids)
      type ? query.of_type(type) : query
    end

    def total_hosts
      hosts.length
    end

    # Retrieve the list of accessible host collections in the organization specified, returning
    # them in the following arrays:
    #   critical: those collections that have 1 or more security errata that need to be applied
    #   warning: those collections that have 1 or more non-security errata that need to be applied
    #   ok: those collections that are completely up to date
    def self.lists_by_updates_needed(organizations)
      host_collections_hash = {}
      host_collections = HostCollection.where(:organization_id => organizations).readable

      # determine the state (critical/warning/ok) for each host collection
      host_collections.each do |host_collection|
        host_collection_state = :ok
        unless host_collection.hosts.empty?
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

    def security_updates?
      errata.any? { |erratum| erratum.errata_type == Erratum::SECURITY }
    end

    def bugzilla_updates?
      errata.any? { |erratum| erratum.errata_type == Erratum::BUGZILLA }
    end

    def enhancement_updates?
      errata.any? { |erratum| erratum.errata_type == Erratum::ENHANCEMENT }
    end

    private

    def perform_group_action
      group = Katello::Pulp::ConsumerGroup.new
      group.pulp_id = SecureRandom.uuid
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
