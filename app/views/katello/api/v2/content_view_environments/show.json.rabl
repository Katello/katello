object @resource
extends 'katello/api/v2/common/identifier'

extends 'katello/api/v2/common/timestamps'
attributes :default_environment? => :default

child :organization => :organization do
  attributes :name, :label, :id
end

node :content_view do |cve|
  cve.content_view&.slice(:id, :name, :label, :default)
end

node :lifecycle_environment do |cve|
  cve.environment&.slice(:id, :name, :label, :library)
end

node :environment do |cve|
  cve.environment&.slice(:id, :name, :label, :library)
end

child :activation_keys => :activation_keys do
  attributes :id, :name, :label
end

node :activation_keys_count do |cve|
  cve.activation_keys.count
end

node :hosts_count do |cve|
  cve.hosts.count
end
