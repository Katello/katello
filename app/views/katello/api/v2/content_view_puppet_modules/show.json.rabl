object @resource

attributes :id
attributes :uuid
attributes :name
attributes :author
attributes :created_at
attributes :updated_at
attributes :computed_version

child :puppet_module => :puppet_module do |puppet_module|
  extends 'katello/api/v2/puppet_modules/show'
end
