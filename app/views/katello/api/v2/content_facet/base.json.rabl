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
  node :content_view do |cvenv|
    {
      id: cvenv.content_view&.id,
      name: cvenv.content_view&.name,
      label: cvenv.content_view&.label,
      composite: cvenv.content_view&.composite,
      rolling: cvenv.content_view&.rolling,
      content_view_version: cvenv.content_view_version&.version,
      content_view_version_id: cvenv.content_view_version&.id,
      content_view_version_latest: cvenv.content_view_version&.latest?,
      content_view_default: cvenv.content_view&.default?,
    }
  end
  node :lifecycle_environment do |cvenv|
    {
      id: cvenv.lifecycle_environment&.id,
      name: cvenv.lifecycle_environment&.name,
      label: cvenv.lifecycle_environment&.label,
      lifecycle_environment_library: cvenv.lifecycle_environment&.library?,
    }
  end
  node :label do |cvenv|
    cvenv.label
  end
  node :id do |cvenv|
    cvenv.id
  end
end

attributes :content_view_environment_labels

node :multi_content_view_environment do |content_facet|
  content_facet.multi_content_view_environment?
end

node :content_view_environments_all_default_or_rolling do |content_facet|
  content_facet.content_view_environments_all_default_or_rolling?
end

node :allow_multiple_content_views do
  Setting['allow_multiple_content_views']
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
