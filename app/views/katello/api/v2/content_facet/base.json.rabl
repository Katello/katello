attributes :id, :uuid
attributes :content_view_id, :content_view_name
attributes :lifecycle_environment_id, :lifecycle_environment_name
attributes :content_source_id, :content_source_name
attributes :kickstart_repository_id, :kickstart_repository_name
attributes :errata_counts
attributes :applicable_deb_count => :applicable_deb_count
attributes :upgradable_deb_count => :upgradable_deb_count
attributes :applicable_rpm_count => :applicable_package_count
attributes :upgradable_rpm_count => :upgradable_package_count
attributes :applicable_module_stream_count, :upgradable_module_stream_count

node :content_view do |content_facet|
  content_view = content_facet.single_content_view
  {
    :id => content_view.id,
    :name => content_view.name,
    :composite => content_view.composite?
  }
end

node :lifecycle_environment do |content_facet|
  lifecycle_environment = content_facet.single_lifecycle_environment
  {
    :id => lifecycle_environment.id,
    :name => lifecycle_environment.name
  }
end

child :content_views => :content_views do
  attributes :id, :name, :composite
end

child :lifecycle_environments => :lifecycle_environments do
  attributes :id, :name
end

child :content_source => :content_source do
  attributes :id, :name, :url
end

child :kickstart_repository => :kickstart_repository do
  attributes :id, :name
end
