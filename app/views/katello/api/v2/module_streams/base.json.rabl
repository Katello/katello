object @resource

attributes :id, :name, :pulp_id, :version, :context, :stream,
           :arch, :description, :summary, :module_spec
attributes :pulp_id => :uuid
node(:name_stream_version_context) { |ms| "#{ms.name}:#{ms.stream}:#{ms.version}:#{ms.context}" }
