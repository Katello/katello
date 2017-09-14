attributes :id, :uuid
attributes :content_view_id, :content_view_name
attributes :lifecycle_environment_id, :lifecycle_environment_name
attributes :content_source_id, :content_source_name
attributes :kickstart_repository_id, :errata_counts
attributes :applicable_rpm_count => :applicable_package_count
attributes :upgradable_rpm_count => :upgradable_package_count

child :content_view => :content_view do
  attributes :id, :name
end

child :lifecycle_environment => :lifecycle_environment do
  attributes :id, :name
end

child :content_source => :content_source do
  attributes :id, :name, :url
end
