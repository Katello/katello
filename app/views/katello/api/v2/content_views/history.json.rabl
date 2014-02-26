
collection @collection

attributes :user, :status, :created_at
attributes :katello_environment_id => :environment_id

node :environment_name do |h|
  h.environment.name
end

node :version do |h|
  h.content_view_version.version
end

node :version_id do |h|
  h.content_view_version.id
end
