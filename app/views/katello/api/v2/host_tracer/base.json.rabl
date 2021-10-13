object @resource ||= @object

attributes :id
attributes :application
attributes :helper
attributes :restart_command
attributes :app_type
attributes :host_id, :host
attributes :reboot_required? => :reboot_required
