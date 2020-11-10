object @organization

extends "api/v2/taxonomies/show"

attributes :task_id, :label, :redhat_repository_url

attributes :system_purposes, :system_purposes
attributes :service_levels, :service_level

node :simple_content_access do |org|
  org.simple_content_access?
end

node :owner_details do |org|
  partial('katello/api/v2/organizations/owner_details', object: OpenStruct.new(org.owner_details))
end

node :default_content_view_id do |org|
  org.default_content_view.id
end

node :library_id do |org|
  org.library.id
end
