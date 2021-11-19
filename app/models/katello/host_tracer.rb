module Katello
  class HostTracer < Katello::Model
    include Katello::Authorization::HostTracer

    belongs_to :host, :inverse_of => :host_traces, :class_name => '::Host::Managed'

    scope :reboot_required, -> { where(app_type: 'static') }
    scope :selectable, -> { where.not(app_type: 'session') }

    validates :application, :length => {:maximum => 255}, :presence => true
    validates :app_type, :length => {:maximum => 255}, :presence => true

    scoped_search :on => :id, :only_explicit => true
    scoped_search :on => :application, :complete_value => true
    scoped_search :on => :app_type, :complete_value => true
    scoped_search :on => :helper, :complete_value => true

    def reboot_required?
      self.app_type == 'static'
    end

    def restart_command
      case self.app_type
      when 'static'
        'reboot'
      when 'session'
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
