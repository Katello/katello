module Katello
  class HostTracer < Katello::Model
    include Katello::Authorization::HostTracer

    belongs_to :host, :inverse_of => :host_traces, :class_name => '::Host::Managed'

    scope :reboot_required, -> { where(app_type: 'static') }

    validates :application, :length => {:maximum => 255}, :presence => true
    validates :app_type, :length => {:maximum => 255}, :presence => true

    scoped_search :on => :application, :complete_value => true
    scoped_search :on => :app_type
    scoped_search :on => :helper

    def reboot_required?
      self.app_type == 'static'
    end
  end
end
