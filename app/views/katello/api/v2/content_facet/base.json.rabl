attributes :id, :uuid
attributes :content_view_id, :content_view_name
attributes :lifecycle_environment_id, :lifecycle_environment_name
attributes :content_source_id, :content_source_name
attributes :kickstart_repository_id, :kickstart_repository_name
attributes :errata_counts
attributes :applicable_rpm_count => :applicable_package_count
attributes :upgradable_rpm_count => :upgradable_package_count
attributes :applicable_module_stream_count, :upgradable_module_stream_count

child :content_view => :content_view do
  attributes :id, :name, :composite
end

child :lifecycle_environment => :lifecycle_environment do
  attributes :id, :name
end

child :content_source => :content_source do
  attributes :id, :name, :url
end

child :kickstart_repository => :kickstart_repository do
  attributes :id, :name
end
