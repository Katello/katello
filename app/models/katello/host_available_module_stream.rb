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

    STATUS = [ENABLED, DISABLED, UNKNOWN].freeze

    API_STATES = {
      ENABLED => :enabled,
      DISABLED => :disabled,
      UNKNOWN => :unknown,
      INSTALLED => :installed
    }.with_indifferent_access

    scoped_search :on => :name, :relation => :available_module_stream, :complete_value => true
    scoped_search :on => :stream, :relation => :available_module_stream, :complete_value => false
    scoped_search :on => :status, :complete_value => STATUS
  end
end
