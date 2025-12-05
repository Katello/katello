module Katello
  class HostInstalledPackage < Katello::Model
    # NOTE: Do not use active record callbacks in this model.
    # Direct DELETEs, INSERTs, and UPDATEs are done which bypass active record callbacks.
    belongs_to :host, :inverse_of => :host_installed_packages, :class_name => '::Host::Managed'
    belongs_to :installed_package, :inverse_of => :host_installed_packages, :class_name => 'Katello::InstalledPackage'

    PERSISTENCE_VALUES = %w[transient persistent].freeze

    # Technically this validation is skipped during bulk operations, but it's here for safety in case of future code changes
    validates :persistence, inclusion: { in: PERSISTENCE_VALUES }, allow_nil: true

    scope :transient, -> { where(persistence: 'transient') }
    scope :persistent, -> { where(persistence: 'persistent') }
  end
end
