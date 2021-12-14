class MigrateContentHosts < ActiveRecord::Migration[4.2]
  HYPERVISOR_CLASS = 'Katello::Hypervisor'.freeze

  class Location < ApplicationRecord
    self.table_name = "taxonomies"

    def self.default_location
      location = MigrateContentHosts::Location.where(:katello_default => true).first
      location.becomes(MigrateContentHosts::Location)
    end
  end

  class Organization < ApplicationRecord
    self.table_name = "taxonomies"

    has_many :kt_environments, :class_name => "MigrateContentHosts::KTEnvironment",
             :dependent => :restrict_with_exception, :inverse_of => :organization
  end

  class SmartProxy < ApplicationRecord
    self.table_name = "smart_proxies"

    belongs_to :content_host, :class_name => "MigrateContentHosts::System", :inverse_of => :capsule
  end

  class KTEnvironment < ApplicationRecord
    self.table_name = "katello_environments"

    belongs_to :organization, :class_name => "MigrateContentHosts::Organization", :inverse_of => :kt_environments

    has_many :content_facets, :class_name => "MigrateContentHosts::ContentFacet", :foreign_key => :lifecycle_environment_id,
             :inverse_of => :lifecycle_environment, :dependent => :restrict_with_exception
    has_many :systems, :class_name => "MigrateContentHosts::System", :inverse_of => :environment,
             :dependent => :restrict_with_exception, :foreign_key => :environment_id
  end

  class ContentView < ApplicationRecord
    self.table_name = "katello_content_views"

    has_many :systems, :class_name => "MigrateContentHosts::System", :dependent => :restrict_with_exception
    has_many :content_facets, :class_name => "MigrateContentHosts::ContentFacet",
             :inverse_of => :content_view, :dependent => :restrict_with_exception
  end

  class Repository < ApplicationRecord
    self.table_name = "katello_repositories"

    has_many :content_facet_repositories, :class_name => "MigrateContentHosts::ContentFacetRepository", :dependent => :destroy
    has_many :content_facets, :through => :content_facet_repositories

    has_many :system_repositories, :class_name => "MigrateContentHosts::SystemRepository", :dependent => :destroy
    has_many :systems, :through => :system_repositories
  end

  class SystemRepository < ApplicationRecord
    self.table_name = "katello_system_repositories"
    belongs_to :system, :inverse_of => :system_repositories, :class_name => 'MigrateContentHosts::System'
    belongs_to :repository, :inverse_of => :system_repositories, :class_name => 'MigrateContentHosts::Repository'
  end

  class HostCollection < ApplicationRecord
    self.table_name = "katello_host_collection"

    has_many :system_host_collections, :class_name => "MigrateContentHosts::SystemHostCollection", :dependent => :destroy
    has_many :systems, :through => :system_host_collections, :class_name => "MigrateContentHosts::System"
  end

  class SystemHostCollections < ApplicationRecord
    self.table_name = "katello_system_host_collections"

    belongs_to :system, :inverse_of => :system_host_collections, :class_name => 'MigrateContentHosts::System'
    belongs_to :host_collection, :inverse_of => :system_host_collections
  end

  class Erratum < ApplicationRecord
    self.table_name = "katello_errata"

    has_many :systems_applicable, :through => :system_errata, :class_name => "MigrateContentHosts::System", :source => :system
    has_many :content_facet_errata, :class_name => "MigrateContentHosts::ContentFacetErratum", :source => :erratum
  end

  class SystemErratum < ApplicationRecord
    self.table_name = "katello_system_errata"

    belongs_to :system, :inverse_of => :system_errata, :class_name => 'MigrateContentHosts::System'
    belongs_to :erratum, :inverse_of => :system_errata, :class_name => 'MigrateContentHosts::Erratum'
  end

  class ActivationKey < ApplicationRecord
    self.table_name = "katello_activation_keys"

    has_many :system_activation_keys, :class_name => "MigrateContentHosts::SystemActivationKey", :dependent => :destroy
    has_many :subscription_facet_activation_keys, :class_name => "MigrateContentHosts::SubscriptionFacetActivationKey", :dependent => :destroy
    has_many :subscription_facets, :through => :subscription_facet_activation_keys
  end

  class SystemActivationKey < ApplicationRecord
    self.table_name = "katello_system_activation_keys"

    belongs_to :system, :inverse_of => :system_activation_keys
    belongs_to :activation_key, :inverse_of => :system_activation_keys
  end

  class Host < ApplicationRecord
    self.table_name = "hosts"
    self.inheritance_column = nil

    has_one :content_facet, :class_name => "MigrateContentHosts::ContentFacet", :dependent => :destroy
    has_one :subscription_facet, :class_name => "MigrateContentHosts::SubscriptionFacet", :dependent => :destroy

    belongs_to :organization, :class_name => "MigrateContentHosts::Organization"
    belongs_to :location, :class_name => "MigrateContentHosts::Location"
  end

  class System < ApplicationRecord
    self.table_name = "katello_systems"
    self.inheritance_column = nil

    def backend_data
      @data ||= ::Katello::Resources::Candlepin::Consumer.get(uuid)
    end

    def facts
      backend_data[:facts]
    end

    belongs_to :content_view, :inverse_of => :systems, :class_name => "MigrateContentHosts::ContentView"
    belongs_to :environment, :class_name => "MigrateContentHosts::KTEnvironment", :inverse_of => :systems

    has_many :system_activation_keys, :class_name => "MigrateContentHosts::SystemActivationKey", :dependent => :destroy
    has_many :activation_keys, :through => :system_activation_keys
    has_many :system_host_collections, :class_name => "MigrateContentHosts::SystemHostCollections", :dependent => :destroy
    has_many :host_collections, :through => :system_host_collections
    has_many :applicable_errata, :through => :system_errata, :class_name => "MigrateContentHosts::Erratum", :source => :erratum
    has_many :system_errata, :class_name => "MigrateContentHosts::SystemErratum", :dependent => :destroy, :inverse_of => :system
    has_many :bound_repositories, :through => :system_repositories, :class_name => "MigrateContentHosts::Repository", :source => :repository
    has_many :system_repositories, :class_name => "MigrateContentHosts::SystemRepository", :dependent => :destroy, :inverse_of => :system

    has_one :capsule, :class_name => "MigrateContentHosts::SmartProxy", :inverse_of => :content_host, :foreign_key => :content_host_id, :dependent => :nullify
  end

  class ContentFacet < ApplicationRecord
    self.table_name = "katello_content_facets"

    belongs_to :host, :inverse_of => :content_facet, :class_name => "MigrateContentHosts::Host"
    belongs_to :content_view, :inverse_of => :content_facets, :class_name => "MigrateContentHosts::ContentView"
    belongs_to :lifecycle_environment, :inverse_of => :content_facets, :class_name => "MigrateContentHosts::KTEnvironment"

    has_many :content_facet_repositories, :class_name => "MigrateContentHosts::ContentFacetRepository", :dependent => :destroy, :inverse_of => :content_facet
    has_many :bound_repositories, :through => :content_facet_repositories, :class_name => "MigrateContentHosts::Repository", :source => :repository
    has_many :applicable_errata, :through => :content_facet_errata, :class_name => "MigrateContentHosts::Erratum", :source => :erratum
    has_many :content_facet_errata, :class_name => "MigrateContentHosts::ContentFacetErratum", :dependent => :destroy, :inverse_of => :content_facet
  end

  class ContentFacetRepository < ApplicationRecord
    self.table_name = "katello_content_facet_repositories"

    belongs_to :content_facet, :inverse_of => :content_facet_repositories, :class_name => 'MigrateContentHosts::ContentFacet'
    belongs_to :repository, :inverse_of => :content_facet_repositories, :class_name => 'MigrateContentHosts::Repository'
  end

  class ContentFacetErratum < ApplicationRecord
    self.table_name = "katello_content_facet_errata"

    belongs_to :content_facet, :inverse_of => :content_facet_errata, :class_name => 'MigrateContentHosts::ContentFacet'
    belongs_to :erratum, :inverse_of => :content_facet_errata, :class_name => 'MigrateContentHosts::Erratum'
  end

  class SubscriptionFacet < ApplicationRecord
    self.table_name = "katello_subscription_facets"

    belongs_to :host, :inverse_of => :subscription_facet, :class_name => "MigrateContentHosts::Host"
    has_many :activation_keys, :through => :subscription_facet_activation_keys, :class_name => "MigrateContentHosts::ActivationKey"
    has_many :subscription_facet_activation_keys, :class_name => "MigrateContentHosts::SubscriptionFacetActivationKey", :dependent => :destroy, :inverse_of => :subscription_facet
  end

  class SubscriptionFacetActivationKey < ApplicationRecord
    self.table_name = "katello_subscription_facet_activation_keys"

    belongs_to :subscription_facet, :inverse_of => :subscription_facet_activation_keys, :class_name => 'MigrateContentHosts::SubscriptionFacet'
    belongs_to :activation_key, :inverse_of => :subscription_facet_activation_keys, :class_name => 'MigrateContentHosts::ActivationKey'
  end

  def logger
    Rails.logger
  end

  def create_content_facet(host, system, include_env_and_view_only = false)
    logger.info("Creating content facet for host #{host.name}.")
    content_facet = host.content_facet = MigrateContentHosts::ContentFacet.new(:content_view => system.content_view,
                                                         :lifecycle_environment => system.environment)
    unless include_env_and_view_only
      content_facet.uuid = system.uuid
      content_facet.bound_repositories = system.bound_repositories
      content_facet.applicable_errata = system.applicable_errata
    end
    content_facet.save!
  end

  def create_subscription_facet(host, system)
    logger.info("Creating subscription facet for host #{host.name}.")
    subscription_facet = host.subscription_facet = MigrateContentHosts::SubscriptionFacet.new
    subscription_facet.activation_keys = system.activation_keys.uniq
    subscription_facet.uuid = system.uuid
    subscription_facet.save!
  end

  def get_systems_with_facts(systems)
    systems_to_remove = []
    systems = systems.to_a

    systems.each do |system|
      facts = system.facts
      unless facts
        systems_to_remove.push(system)
      end
    rescue RestClient::Exception
      systems_to_remove.push(system)
    end

    systems_to_remove.each do |system|
      logger.info("Content Host #{system.uuid} doesn't have candlepin information, unregistering.")
      if (system_proxy = SmartProxy.find_by_content_host_id(system.id))
        system_proxy.content_host_id = nil
        system_proxy.save
      end
      systems.delete(system)
      unregister_system(system)
    end

    systems
  end

  def group_systems_by_hostname(systems)
    system_hostnames = {}

    systems.each do |system|
      hostname = system.facts['network.hostname']

      if system_hostnames[hostname]
        system_hostnames[hostname].push(system)
      else
        system_hostnames[hostname] = [system]
      end
    end

    system_hostnames
  end

  def ensure_one_system_per_hostname(systems)
    # ensure only one system exists per hostname and unregister all except the last registered
    systems = get_systems_with_facts(systems)
    system_hostnames = group_systems_by_hostname(systems)

    system_hostnames.each do |hostname, duplicate_systems|
      if duplicate_systems.count > 1
        logger.warn("Multiple content hosts with the hostname #{hostname} found, unregistering all except last registered.")
        unregister_all_but_last_system(duplicate_systems)
      end
    end
  end

  def unregister_system(system)
    logger.warn("Unregistering content host with UUID: #{system.uuid}")

    begin
      logger.info("Removing Candlepin consumer #{system.uuid}")
      Katello::Resources::Candlepin::Consumer.destroy(system.uuid)
    rescue RestClient::Exception => e
      logger.warn("Exception when destroying candlepin consumer #{system.uuid}:#{e.inspect}")
    end

    begin
      logger.info("Removing Pulp consumer #{system.uuid}")
      Katello.pulp_server.extensions.consumer.delete(system.uuid)
    rescue RestClient::ResourceNotFound
      logger.warn("Pulp consumer not found for consumer #{system.uuid} proceeding.")
      #do nothing
    rescue RestClient::Exception => e
      logger.warn("Exception when destroying pulp consumer #{system.uuid}:#{e.inspect}")
    end

    logger.info("Removing system #{system.uuid}")
    system.destroy
  end

  def unregister_all_but_last_system(systems)
    systems_by_created_date = systems.sort_by(&:created_at)
    system = systems_by_created_date.pop

    systems_by_created_date.each do |system_to_remove|
      unregister_system(system_to_remove)
    end

    system
  end

  def handle_hypervisors
    MigrateContentHosts::System.where(:type => HYPERVISOR_CLASS).find_each do |hypervisor|
      org = hypervisor.environment.organization
      name = "virt-who-#{hypervisor.name}-#{org.id}"

      host = ::Host.find_by(:name => name)
      if host.nil?
        host = MigrateContentHosts::Host.create!(:name => name, :organization => org.becomes(MigrateContentHosts::Organization), :managed => false,
                                             :type => "Host::Managed", :location => MigrateContentHosts::Location.default_location)
      elsif host.organization != org
        logger.warn("Found host with name #{name} but it's in org #{host.organization.name} instead of #{org.name}.")
        unregister_system(hypervisor)
        next
      end
      hypervisor.host_id = host.id
      hypervisor.save!
      create_subscription_facet(host, hypervisor) unless host.subscription_facet
      update_hypervisor_consumer(hypervisor)
    end
  end

  def update_hypervisor_consumer(hypervisor)
    org = hypervisor.environment.organization
    hypervisor.content_view = org.default_content_view.becomes(MigrateContentHosts::ContentView)
    hypervisor.environment = org.library.becomes(MigrateContentHosts::KTEnvironment)
    hypervisor.save!

    candlepin_environment_id = org.default_content_view.content_view_environments.first.cp_id
    ::Katello::Resources::Candlepin::Consumer.update(hypervisor.uuid, 'environment' => {'id' => candlepin_environment_id})
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def up
    unless User.unscoped.where(:login => User::ANONYMOUS_API_ADMIN).exists?
      logger.warn("Foreman anonymous admin does not exist, skipping content host migration.")
      return
    end

    User.current = User.anonymous_api_admin
    system_count = ::MigrateContentHosts::System.all.count

    return true if system_count == 0

    ping = ::Katello::Ping.ping
    if ping[:status] != ::Katello::Ping::OK_RETURN_CODE
      fail _("Some backend services are not running: %s") % ping.inspect
    end

    ::MigrateContentHosts::System.where(:uuid => nil).destroy_all

    ensure_one_system_per_hostname(MigrateContentHosts::System.where("type != '#{HYPERVISOR_CLASS}'").all)

    systems = get_systems_with_facts(MigrateContentHosts::System.where("type != '#{HYPERVISOR_CLASS}'").all)

    systems.each do |system|
      system.environment.organization = system.environment.organization.becomes(MigrateContentHosts::Organization)
      hostname = system.facts['network.hostname']

      logger.info("Processing content host #{system.uuid} #{hostname}")

      if hostname.nil?
        logger.warn("Content host #{system.uuid} does not have a hostname, removing.")
        unregister_system(system)
        next
      end

      MigrateContentHosts::Host.reset_column_information
      hosts = MigrateContentHosts::Host.where(:name => hostname)
      if hosts.empty? # no host exists
        logger.info("No host exists with hostname #{hostname}, creating new host.")
        host = MigrateContentHosts::Host.new(:name => system.facts['network.hostname'], :organization => system.environment.organization,
                                             :type => "Host::Managed", :location => MigrateContentHosts::Location.default_location, :managed => false)
        host.save!

        create_content_facet(host, system)
        create_subscription_facet(host, system)

      elsif hosts.where(:organization_id => system.environment.organization.id).empty? # host is not in the correct org
        if hosts[0].organization
          logger.warn("Found host with hostname #{hostname} but it's in org #{hosts[0].organization.name} instead of #{system.environment.organization.name}.")
        else
          logger.warn("Found host with hostname #{hostname} but it is not in an org, and should be in #{system.environment.organization.name}.")
        end
        host = hosts.first

        create_content_facet(host, system, true) unless host.content_facet
        unregister_system(system)

      else #host exists in the correct org
        logger.info("Found host with hostname #{hostname}.")
        host = hosts.first

        create_content_facet(host, system) unless host.content_facet
        create_subscription_facet(host, system) unless host.subscription_facet
      end

      unless system.destroyed? # if the system was unregistered, it will no longer exist
        system.host_id = host.id
        system.save!
      end
    end

    handle_hypervisors
  end
end
