module Katello
  class HostTracer < Katello::Model
    include Katello::Authorization::HostTracer

    TRACE_APP_TYPE_STATIC = 'static'.freeze
    TRACE_APP_TYPE_SESSION = 'session'.freeze
    TRACE_APP_TYPE_DAEMON = 'daemon'.freeze

    belongs_to :host, :inverse_of => :host_traces, :class_name => '::Host::Managed'

    scope :reboot_required, -> { where(app_type: TRACE_APP_TYPE_STATIC) }
    scope :selectable, -> { where.not(app_type: TRACE_APP_TYPE_SESSION) }

    validates :application, :length => {:maximum => 255}, :presence => true
    validates :app_type, :length => {:maximum => 255}, :presence => true

    scoped_search :on => :id, :only_explicit => true
    scoped_search :on => :application, :complete_value => true
    scoped_search :on => :app_type, :complete_value => true
    scoped_search :on => :helper, :complete_value => true

    def reboot_required?
      self.app_type == TRACE_APP_TYPE_STATIC
    end

    def restart_command
      case self.app_type
      when TRACE_APP_TYPE_STATIC
        'reboot'
      when TRACE_APP_TYPE_SESSION
        nil
      else
        self.helper
      end
    end

    def self.helpers_for(traces)
      if traces.any?(&:reboot_required?)
        ['reboot']
      else
        traces.map(&:restart_command).compact.uniq
      end
    end
  end
end
