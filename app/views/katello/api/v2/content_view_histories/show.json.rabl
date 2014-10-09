object @resource

attributes :user, :status

child :environment => :environment do |h|
  attributes :id, :name
end

node :version do |h|
  h.content_view_version.version
end

node :publish do |h|
  h.environment.nil?
end

node :version_id do |h|
  h.content_view_version.id
end

child :task => :task do
  extends 'foreman_tasks/api/tasks/show'
end

extends 'katello/api/v2/common/timestamps'
