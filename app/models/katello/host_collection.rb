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
      if !unlimited_hosts && (hosts.length > 0 && (hosts.length.to_i > max_hosts.to_i)) && max_hosts_changed?
        errors.add :max_host, N_("may not be less than the number of hosts associated with the host collection.")
      end
    end

    def max_hosts_not_exceeded
      if !unlimited_hosts && (hosts.size.to_i > max_hosts.to_i)
        errors.add :base, N_("You cannot have more than #{max_hosts} host(s) associated with host collection #{name}." %
                              {:max_hosts => max_hosts, :name => name})
      end
    end

    belongs_to :organization, :inverse_of => :host_collections

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
      query = Erratum.joins(:content_facets).where("#{Katello::Host::ContentFacet.table_name}.host_id" => self.host_ids)
      type ? query.of_type(type) : query
    end

    def total_hosts
      hosts.count
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

    def security_updates?
      errata(Erratum::SECURITY).any?
    end

    def bugzilla_updates?
      errata(Erratum::BUGZILLA).any?
    end

    def enhancement_updates?
      errata(Erratum::ENHANCEMENT).any?
    end

    def self.humanize_class_name(_name = nil)
      _("Host Collections")
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
