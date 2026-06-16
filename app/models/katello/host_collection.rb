module Katello
  class HostCollection < Katello::Model
    audited
    include Katello::Authorization::HostCollection

    has_many :key_host_collections, :class_name => "Katello::KeyHostCollection", :dependent => :destroy
    has_many :activation_keys, :through => :key_host_collections

    has_many :host_collection_hosts, :class_name => "Katello::HostCollectionHosts", :dependent => :destroy
    has_many :hosts, :through => :host_collection_hosts, :class_name => "::Host::Managed"

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
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :relation => :hosts, :on => :name, :rename => :host, :complete_value => true

    def max_hosts_check
      # NOTE: max_hosts_check and max_hosts_no_exceeded use size() instead of count() because
      # the host list exists as an array rather than a DB query when run as a validation.
      host_count = hosts.size
      if !unlimited_hosts && host_count > 0 && (host_count.to_i > max_hosts.to_i) && max_hosts_changed?
        errors.add :max_host, N_("may not be less than the number of hosts associated with the host collection.")
      end
    end

    def max_hosts_not_exceeded
      if !unlimited_hosts && (hosts.size.to_i > max_hosts.to_i)
        errors.add :base, max_hosts_exceeded_message
      end
    end

    belongs_to :organization, :inverse_of => :host_collections

    def consumer_ids
      consumer_ids = []

      self.hosts.each do |host|
        if host.subscription_facet
          consumer_ids.push(host.subscription_facet.uuid)
        end
      end

      consumer_ids
    end

    def errata(type = nil, installable_only: false)
      query = if installable_only
                Katello::Erratum.installable_for_hosts(self.hosts)
              else
                Katello::Erratum.applicable_to_hosts(self.hosts)
              end
      type ? query.of_type(type) : query
    end

    def cache_key
      "#{self.class.name}/#{self.id}"
    end

    def total_hosts(cached: false)
      Rails.cache.fetch("#{cache_key}/total_hosts", expires_in: 1.minute, force: !cached) do
        hosts.count
      end
    end

    def add_host_ids!(requested_host_ids:, authorized_host_ids:)
      update_host_membership(requested_host_ids, authorized_host_ids) do |existing_host_ids, allowed_host_ids|
        host_ids_to_add = allowed_host_ids - existing_host_ids
        ensure_capacity_for!(host_ids_to_add.length)
        create_host_collection_hosts(host_ids_to_add)

        {
          :updated_host_ids => host_ids_to_add,
          :requested_existing_host_ids => existing_host_ids,
        }
      end
    end

    def remove_host_ids!(requested_host_ids:, authorized_host_ids:)
      update_host_membership(requested_host_ids, authorized_host_ids) do |existing_host_ids, allowed_host_ids|
        host_ids_to_remove = existing_host_ids & allowed_host_ids
        destroy_host_collection_hosts(host_ids_to_remove)

        {
          :updated_host_ids => host_ids_to_remove,
          :requested_existing_host_ids => existing_host_ids,
        }
      end
    end

    def max_hosts_exceeded_message
      _("You cannot have more than %{max_hosts} host(s) associated with host collection %{host_collection}.") %
        { :max_hosts => max_hosts, :host_collection => name }
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
          host_collection_state = host_collection.security_updates? ? :critical : :warning
        end

        host_collections_hash[host_collection_state] ||= []
        host_collections_hash[host_collection_state] << host_collection
      end
      return host_collections_hash[:critical].to_a, host_collections_hash[:warning].to_a, host_collections_hash[:ok].to_a
    end

    def security_updates?(installable_only: false)
      errata(Erratum::SECURITY, installable_only: installable_only).any?
    end

    def bugzilla_updates?(installable_only: false)
      errata(Erratum::BUGZILLA, installable_only: installable_only).any?
    end

    def enhancement_updates?(installable_only: false)
      errata(Erratum::ENHANCEMENT, installable_only: installable_only).any?
    end

    def self.humanize_class_name(_name = nil)
      _("Host Collections")
    end

    private

    def update_host_membership(requested_host_ids, authorized_host_ids)
      normalized_requested_host_ids = normalize_host_ids(requested_host_ids)
      normalized_authorized_host_ids = normalize_host_ids(authorized_host_ids)
      allowed_host_ids = normalized_requested_host_ids & normalized_authorized_host_ids

      return empty_membership_result if normalized_requested_host_ids.empty?

      with_lock do
        existing_host_ids = host_collection_hosts.where(:host_id => normalized_requested_host_ids).pluck(:host_id)
        result = yield(existing_host_ids, allowed_host_ids)

        clear_membership_cache if result[:updated_host_ids].any?

        result
      end
    end

    def empty_membership_result
      {
        :updated_host_ids => [],
        :requested_existing_host_ids => [],
      }
    end

    def normalize_host_ids(host_ids)
      Array(host_ids).map(&:to_i).uniq
    end

    def ensure_capacity_for!(additional_host_count)
      return if additional_host_count.zero? || unlimited_hosts

      if host_collection_hosts.count + additional_host_count > max_hosts
        errors.add(:base, max_hosts_exceeded_message)
        fail ActiveRecord::RecordInvalid, self
      end
    end

    def create_host_collection_hosts(host_ids)
      return if host_ids.empty?

      timestamp = Time.current
      HostCollectionHosts.insert_all(
        host_ids.map do |host_id|
          {
            :host_collection_id => id,
            :host_id => host_id,
            :created_at => timestamp,
            :updated_at => timestamp,
          }
        end
      )
    end

    def destroy_host_collection_hosts(host_ids)
      return if host_ids.empty?

      host_collection_hosts.where(:host_id => host_ids).delete_all
    end

    def clear_membership_cache
      association(:host_collection_hosts).reset
      association(:hosts).reset
      Rails.cache.delete("#{cache_key}/total_hosts")
    end

    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Host Collection'
      refs 'HostCollection'
      sections only: %w[all additional]
      property :name, String, desc: 'Returns name of the host collection'
    end
    class Jail < ::Safemode::Jail
      allow :name
    end
  end
end
