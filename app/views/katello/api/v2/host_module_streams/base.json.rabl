object @resource

attributes :status, :installed_profiles

glue(@object.available_module_stream) do
  attributes :name, :stream, :module_spec
end
