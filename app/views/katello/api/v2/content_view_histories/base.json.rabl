object @resource

attributes :user, :status

child :environment => :environment do |_h|
  attributes :id, :name
end

node :version do |h|
  h.content_view_version.version
end

node :description do |h|
  h.content_view_version.description
end

node :publish do |h|
  h.environment.nil?
end

node :version_id do |h|
  h.content_view_version.id
end

extends 'katello/api/v2/common/timestamps'
