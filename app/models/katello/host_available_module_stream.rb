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
    scoped_search :on => :status, :complete_value => STATUS

    def upgradable?
      return false if status != ENABLED

      ApplicableContentHelper.new(ModuleStream).installable_for_hosts([host_id]).
                                         where(ModuleStream.table_name => {:name => available_module_stream.name,
                                                                           :stream => available_module_stream.stream}).exists?
    end

    def self.upgradable(host)
      upgradable_module_name_streams = ApplicableContentHelper.new(ModuleStream).installable_for_hosts([host]).select(:name, :stream)

      enabled.joins(:available_module_stream).where(:host_id => host).
              where("(#{AvailableModuleStream.table_name}.name, #{AvailableModuleStream.table_name}.stream) in (#{upgradable_module_name_streams.to_sql})")
    end
  end
end
