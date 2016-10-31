module Katello
  class HostTracer < Katello::Model
    self.include_root_in_json = false

    belongs_to :host, :inverse_of => :host_traces, :class_name => '::Host::Managed'

    validates :application, :length => {:maximum => 255}, :presence => true
    validates :app_type, :length => {:maximum => 255}, :presence => true

    scoped_search :on => :application, :complete_value => true
    scoped_search :on => :app_type
    scoped_search :on => :helper
  end
end
