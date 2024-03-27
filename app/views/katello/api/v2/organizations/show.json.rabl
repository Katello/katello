object @organization

extends "api/v2/taxonomies/show"

attributes :task_id, :label, :redhat_repository_url
attributes :manifest_expiration_date, :manifest_expire_days_remaining
attributes :system_purposes, :system_purposes
attributes :service_levels, :service_level

node :manifest_expiring_soon do |org|
  org.manifest_expiring_soon?
end

node :manifest_expired do |org|
  org.manifest_expired?
end

node :simple_content_access do |org|
  org.simple_content_access?
end

node :owner_details do |org|
  partial('katello/api/v2/organizations/owner_details', object: OpenStruct.new(org.owner_details))
end

node :cdn_configuration do |org|
  partial('katello/api/v2/cdn_configurations/show', object: org.cdn_configuration)
end

node :default_content_view_id do |org|
  org.default_content_view.id
end

node(:composite_content_views_count) { Katello::ContentView.readable&.in_organization(Organization.current)&.composite&.count }
node(:content_view_components_count) do
  Katello::ContentView.readable&.
    in_organization(Organization.current)&.
    non_composite&.
    non_default&.
    ignore_generated&.count
end

node :library_id do |org|
  org.library.id
end
