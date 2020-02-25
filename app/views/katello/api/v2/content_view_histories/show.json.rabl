object @resource

attributes :user, :status, :description, :action

child :environment => :environment do |_h|
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

node :triggered_by do |h|
  h.triggered_by&.name
end

node :triggered_by_id do |h|
  h.triggered_by&.id
end

child :task => :task do
  extends 'foreman_tasks/api/tasks/show'
end

extends 'katello/api/v2/common/timestamps'
