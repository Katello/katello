object @resource

attributes :status, :installed_profiles
attributes :upgradable? => :upgradable

glue(@object.available_module_stream) do
  attributes :name, :stream, :module_spec
end
