object @resource

extends 'katello/api/v2/content_view_filters/base'

child :content_view => :content_view do
  extends "katello/api/v2/content_views/base"

  child :repositories => :repositories do
    attributes :id, :name, :label, :content_type

    child :product => :product do
      attributes :id, :name
    end

    node :content_counts do |repo|
      {
        :docker_manifest => repo.docker_manifests.count,
        :docker_tag => repo.docker_tags.count,
        :rpm => repo.rpms.count,
        :package => repo.rpms.count,
        :package_group => repo.package_groups.count,
        :erratum => repo.errata.count,
        :module_stream => repo.module_streams.count
      }
    end
  end
end
