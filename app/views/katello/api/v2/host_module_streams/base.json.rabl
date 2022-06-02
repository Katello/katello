object @resource

attributes :status, :installed_profiles
attributes :upgradable? => :upgradable
attributes :install_status => :install_status

glue(@object.available_module_stream) do
  attributes :id, :name, :stream, :version, :module_spec
end
