object @resource

attributes :id, :name, :uuid, :version, :context, :stream,
           :arch, :description, :summary

child :repositories => :repositories do
  attributes :id, :name
end
