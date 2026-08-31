object @resource
extends 'katello/api/v2/common/identifier'

extends 'katello/api/v2/common/timestamps'
attributes :default_environment? => :default

child :organization => :organization do
  attributes :name, :label, :id
end

node :content_view do |cvenv|
  cvenv.content_view&.slice(:id, :name, :label, :default)
end

node :lifecycle_environment do |cvenv|
  cvenv.environment&.slice(:id, :name, :label, :library)
end

node :environment do |cvenv|
  cvenv.environment&.slice(:id, :name, :label, :library)
end

child :activation_keys => :activation_keys do
  attributes :id, :name, :label
end

node :activation_keys_count do |cvenv|
  cvenv.activation_keys.count
end

node :hosts_count do |cvenv|
  cvenv.hosts.count
end

child :hostgroups => :hostgroups do
  attributes :id, :name, :title
end

node :hostgroups_count do |cvenv|
  cvenv.hostgroups.size
end
