attributes :id, :uuid
attributes :content_source_id, :content_source_name
attributes :kickstart_repository_id, :kickstart_repository_name
attributes :errata_counts
attributes :applicable_deb_count => :applicable_deb_count
attributes :upgradable_deb_count => :upgradable_deb_count
attributes :applicable_rpm_count => :applicable_package_count
attributes :upgradable_rpm_count => :upgradable_package_count
attributes :applicable_module_stream_count, :upgradable_module_stream_count

child :content_view_environments => :content_view_environments do
  node :content_view do |cve|
    {
      id: cve.content_view&.id,
      name: cve.content_view&.name,
      composite: cve.content_view&.composite,
      rolling: cve.content_view&.rolling,
      content_view_version: cve.content_view_version&.version,
      content_view_version_id: cve.content_view_version&.id,
      content_view_version_latest: cve.content_view_version&.latest?,
      content_view_default: cve.content_view&.default?,
    }
  end
  node :lifecycle_environment do |cve|
    {
      id: cve.lifecycle_environment&.id,
      name: cve.lifecycle_environment&.name,
      lifecycle_environment_library: cve.lifecycle_environment&.library?,
    }
  end
  node :label do |cve|
    cve.label
  end
end

attributes :content_view_environment_labels

node :multi_content_view_environment do |content_facet|
  content_facet.multi_content_view_environment?
end

# single cv/lce for backward compatibility
node :content_view do |content_facet|
  content_view = content_facet.single_content_view
  if content_view.present?
    {
      :id => content_view.id,
      :name => content_view.name,
      :composite => content_view.composite?,
      :rolling => content_view.rolling?,
    }
  end
end

node :lifecycle_environment do |content_facet|
  lifecycle_environment = content_facet.single_lifecycle_environment
  if lifecycle_environment.present?
    {
      :id => lifecycle_environment.id,
      :name => lifecycle_environment.name,
    }
  end
end

child :content_source => :content_source do
  attributes :id, :name, :url, :registration_host
  node(:load_balanced) { |content_source| content_source.load_balanced? }
end

child :kickstart_repository => :kickstart_repository do
  attributes :id, :name
end

attributes :bootc_booted_image, :bootc_booted_digest, :bootc_available_image, :bootc_available_digest,
           :bootc_staged_image, :bootc_staged_digest, :bootc_rollback_image, :bootc_rollback_digest
