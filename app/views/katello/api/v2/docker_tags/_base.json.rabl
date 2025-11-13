object @resource

attributes :id, :name
attributes :repository_id

child :schema1_manifest => :manifest_schema1 do
  attributes :pulp_id => :id
  attributes :schema_version, :digest, :manifest_type
end

child :schema2_manifest => :manifest_schema2 do
  attributes :pulp_id => :id
  attributes :schema_version, :digest, :manifest_type
end

child :docker_manifest => :manifest do
  attributes :pulp_id => :id
  attributes :schema_version, :digest, :manifest_type
  attributes :labels, :annotations
  attributes :is_bootable, :is_flatpak
  attributes :created_at, :updated_at

  node :manifests, :if => lambda { |m| m.manifest_type == 'list' } do |manifest|
    manifest.docker_manifests.map do |child_manifest|
      {
        :id => child_manifest.id,
        :digest => child_manifest.digest,
        :schema_version => child_manifest.schema_version,
        :manifest_type => child_manifest.manifest_type,
        :labels => child_manifest.labels,
        :annotations => child_manifest.annotations,
        :is_bootable => child_manifest.is_bootable,
        :is_flatpak => child_manifest.is_flatpak,
        :created_at => child_manifest.created_at,
        :updated_at => child_manifest.updated_at,
      }
    end
  end
end

if @organization
  node :repositories do
    @object.repositories.in_organization(@organization).map do |repo|
      attributes = {
        :id => repo.id,
        :name => repo.name,
        :full_path => repo.full_path,
        :library_instance => repo.library_instance?,
        :product_id => repo.product&.id,
        :product_name => repo.product&.name,
        :kt_environment => (if repo.environment
                              {
                                :id => repo.environment.id,
                                :name => repo.environment.name,
                              }
                            end),
        :content_view_version => (if repo.content_view_version
                                    {
                                      :id => repo.content_view_version.id,
                                      :name => repo.content_view_version.name,
                                      :content_view_id => repo.content_view_version.content_view_id,
                                    }
                                  end),
      }
      attributes
    end
  end
  node :product do
    first_repo = @object.repositories.in_organization(@organization)&.first
    product = first_repo&.product
    attributes = {
      :id => product&.id,
      :name => product&.name,
    }
    attributes
  end
else
  child :repositories => :repositories do
    attributes :id, :name, :full_path
    node :library_instance do |repo|
      repo.library_instance?
    end
    node :product_id do |repo|
      repo.product&.id
    end
    node :product_name do |repo|
      repo.product&.name
    end
    node :kt_environment do |repo|
      if repo.environment
        {
          :id => repo.environment.id,
          :name => repo.environment.name,
        }
      end
    end
    node :content_view_version do |repo|
      if repo.content_view_version
        {
          :id => repo.content_view_version.id,
          :name => repo.content_view_version.name,
          :content_view_id => repo.content_view_version.content_view_id,
        }
      end
    end
  end

  child :product => :product do
    attributes :id, :name
  end
end

node :upstream_name do |item|
  item.upstream_name
end

child :environment => :environment do
  attributes :id, :name
end

child :content_view_version do
  attributes :id, :name, :content_view_id
end
