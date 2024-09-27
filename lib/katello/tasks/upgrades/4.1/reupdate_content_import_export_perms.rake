namespace :katello do
  namespace :upgrades do
    namespace '4.1' do
      desc "Update for content import/export permissions."
      task :reupdate_content_import_export_perms => ['environment'] do
        User.current = User.anonymous_api_admin

        def deduplicate_filters(perm)
          # This method makes sure that the perms [import_content, export_content]
          # are not duplicated in this role
          # This case used to occur if this upgrade script  did not run
          # and the user created a role with
          # import_library_content, export_library_content, import_content, export_content
          # After running this task the output used to be
          # [import_content, import_content, export_content, export_content]
          # This method just ensures that those get cleaned up.

          filtering_map = Filtering.where(permission_id: Permission.where(name: [perm]))
                           .order(:id)
                           .group_by(&:filter_id)
                           .select { |_, value| value.length > 1 }
          filtering_map.values.each do |filterings|
            sliced = filterings[0...-1] # keep the last filtering and destroy the rest
            sliced.each(&:destroy)
          end
        end

        permission_map = {
          Permission.find_by(name: :export_library_content) => Permission.find_by(name: :export_content),
          Permission.find_by(name: :import_library_content) => Permission.find_by(name: :import_content),
        }

        permission_map.each do |old_perm, new_perm|
          Filtering.where(permission_id: old_perm.id).update_all(:permission_id => new_perm.id) if old_perm
        end

        names = permission_map.keys.compact.map(&:name)
        Permission.where(:name => names).destroy_all if names.any?

        deduplicate_filters('import_content')
        deduplicate_filters('export_content')

        export_content_views = Permission.find_by_name(:export_content_views)
        next if export_content_views.blank?

        Filtering.where(permission_id: export_content_views.id).each do |filtering|
          filter = filtering.filter
          filter.role.add_permissions!(:export_content)
          filter.destroy if filter.filterings.count == 1
        end
        Filtering.where(permission_id: export_content_views.id).destroy_all
        export_content_views.destroy
      end
    end
  end
end
