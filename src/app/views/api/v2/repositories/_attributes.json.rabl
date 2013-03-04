attributes :relative_path, :arch, :updated_at, :created_at, :content_view_version_id, :label 
attributes :environment_product_id, :last_sync, :major, :pulp_id, :enabled, :minor, :content_id 
node :package_count do |repo|
  repo.package_count
end
attributes :library_instance_id, :gpg_key_name, :id, :cp_label, :name, :gpg_key_id, :feed
