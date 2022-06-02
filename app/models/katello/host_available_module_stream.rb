module Katello
  class HostAvailableModuleStream < Katello::Model
    belongs_to :host, :inverse_of => :host_available_module_streams, :class_name => '::Host::Managed'
    belongs_to :available_module_stream, :inverse_of => :host_available_module_streams, :class_name => 'Katello::AvailableModuleStream'
    serialize :installed_profiles

    scope :installed, -> { enabled.where.not(installed_profiles: []) }
    scope :enabled, -> { where(status: ENABLED) }
    scope :disabled, -> { where(status: DISABLED) }
    scope :unknown, -> { where(status: UNKNOWN) }

    ENABLED = "enabled".freeze
    DISABLED = "disabled".freeze
    UNKNOWN = "unknown".freeze
    INSTALLED = "installed".freeze
    UPGRADABLE = "upgradable".freeze

    STATUS = [ENABLED, DISABLED, UNKNOWN].freeze

    API_STATES = {
      ENABLED => :enabled,
      DISABLED => :disabled,
      UNKNOWN => :unknown,
      INSTALLED => :installed,
      UPGRADABLE => :upgradable
    }.with_indifferent_access

    scoped_search :on => :name, :relation => :available_module_stream, :complete_value => true
    scoped_search :on => :stream, :relation => :available_module_stream, :complete_value => false
    scoped_search :on => :version, :relation => :available_module_stream, :complete_value => false
    scoped_search :on => :installed_profiles
    scoped_search :on => :status, :complete_value => STATUS

    def upgradable?
      return false if status != ENABLED

      ModuleStream.installable_for_hosts([host_id]).
           where(ModuleStream.table_name => {:name => available_module_stream.name,
                                             :stream => available_module_stream.stream}).exists?
    end

    def install_status
      return 'Not installed' if installed_profiles.blank?
      case status
      when 'disabled'
        'Installed'
      when 'enabled'
        upgradable? ? 'Upgradable' : 'Up-to-date'
      end
    end

    def self.installed_status(status, host)
      case status
      when 'not installed'
        where(installed_profiles: [])
      when 'upgradable'
        where(id: upgradable(host).pluck(:id))
      when 'up to date'
        where(status: 'enabled').where.not(installed_profiles: []).where.not(id: upgradable(host).pluck(:id))
      end
    end

    def self.upgradable(host)
      upgradable_module_name_streams = ModuleStream.installable_for_hosts([host]).select(:name, :stream)

      enabled.joins(:available_module_stream).where(:host_id => host).
              where("(#{AvailableModuleStream.table_name}.name, #{AvailableModuleStream.table_name}.stream) in (#{upgradable_module_name_streams.to_sql})")
    end
  end
end
