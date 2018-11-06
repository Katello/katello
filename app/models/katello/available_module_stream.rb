module Katello
  class AvailableModuleStream < Katello::Model
    has_many :hosts, :through => :host_available_module_streams, :class_name => "::Host"
    has_many :host_available_module_streams, :class_name => "Katello::HostAvailableModuleStream", :dependent => :destroy, :inverse_of => :available_module_stream
    serialize :profiles

    def module_spec
      "#{name}:#{stream}"
    end
  end
end
