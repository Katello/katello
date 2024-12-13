object @resource

@resource ||= @object

attributes :id, :name, :description

node :operatingsystem_family do |resource|
  resource.operatingsystem&.family
end

node :operatingsystem_major do |resource|
  resource.operatingsystem&.major
end
