class CreateContentViewForeignKeys < ActiveRecord::Migration
  def up
    add_foreign_key :katello_content_view_environments, :katello_content_view_versions,
      :name => "katello_content_view_environments_version_fk", :column => 'content_view_version_id'

    add_foreign_key :katello_content_view_components, :katello_content_view_versions,
      :name => "katello_content_view_components_version_fk", :column => 'content_view_version_id'

    add_foreign_key :katello_content_view_components, :katello_content_views,
      :name => "katello_content_view_components_view_fk", :column => 'content_view_id'

    add_foreign_key :katello_content_view_repositories, :katello_content_views,
      :name => "katello_content_view_repostories_content_view_fk", :column => 'content_view_id'

    add_foreign_key :katello_content_view_repositories, :katello_repositories,
      :name => "katello_content_view_repositories_repository_view_fk", :column => 'repository_id'

    add_foreign_key :katello_content_view_filters_repositories, :katello_content_view_filters,
      :name => "katello_content_view_filters_repositories_filter_fk", :column => 'content_view_filter_id'

    add_foreign_key :katello_content_view_filters_repositories, :katello_repositories,
      :name => "katello_content_view_filters_repositories_repository_fk", :column => 'repository_id'

    add_foreign_key :katello_content_view_filters, :katello_content_views,
      :name => "katello_content_view_filters_view_fk", :column => 'content_view_id'

    # new
    add_foreign_key :katello_content_view_puppet_modules, :katello_content_views,
      :name => "katello_content_view_puppet_modules_view_fk", :column => 'content_view_id'

    add_foreign_key :katello_content_view_package_filter_rules, :katello_content_view_filters,
      :name => "katello_content_view_package_filter_rules_filter_fk", :column => 'content_view_filter_id'

    add_foreign_key :katello_content_view_package_group_filter_rules, :katello_content_view_filters,
      :name => "katello_content_view_package_group_filter_rules_filter_fk", :column => 'content_view_filter_id'

    add_foreign_key :katello_content_view_erratum_filter_rules, :katello_content_view_filters,
      :name => "katello_content_view_erratum_filter_rules_filter_fk", :column => 'content_view_filter_id'

    add_foreign_key :katello_content_view_puppet_environments, :katello_content_view_versions,
      :name => "katello_content_view_puppet_environments_view_version_fk", :column => 'content_view_version_id'

    add_foreign_key :katello_content_view_puppet_environments, :katello_environments,
      :name => "katello_content_view_puppet_environments_environment_fk", :column => 'environment_id'

    add_foreign_key :katello_content_views, :taxonomies,
      :name => "katello_content_views_organization_fk", :column => 'organization_id'
  end

  def down
    remove_foreign_key :katello_content_view_environments, :name => "katello_content_view_environments_version_fk"
    remove_foreign_key :katello_content_view_components, :name => "katello_content_view_components_version_fk"
    remove_foreign_key :katello_content_view_components, :name => "katello_content_view_components_view_fk"
    remove_foreign_key :katello_content_view_repositories, :name => "katello_content_view_repostories_content_view_fk"
    remove_foreign_key :katello_content_view_repositories, :name => "katello_content_view_repositories_repository_view_fk"
    remove_foreign_key :katello_content_view_filters_repositories, :name => "katello_content_view_filters_repositories_filter_fk"
    remove_foreign_key :katello_content_view_filters_repositories, :name => "katello_content_view_filters_repositories_repository_fk"
    remove_foreign_key :katello_content_view_filters, :name => "katello_content_view_filters_view_fk"
    remove_foreign_key :katello_content_view_puppet_modules, :name => "katello_content_view_puppet_modules_view_fk"
    remove_foreign_key :katello_content_view_package_filter_rules, :name => "katello_content_view_package_filter_rules_filter_fk"
    remove_foreign_key :katello_content_view_package_group_filter_rules, :name => "katello_content_view_package_group_filter_rules_filter_fk"
    remove_foreign_key :katello_content_view_erratum_filter_rules, :name => "katello_content_view_erratum_filter_rules_filter_fk"
    remove_foreign_key :katello_content_view_puppet_environments, :name => "katello_content_view_puppet_environments_view_version_fk"
    remove_foreign_key :katello_content_view_puppet_environments, :name => "katello_content_view_puppet_environments_environment_fk"
    remove_foreign_key :katello_content_views, :name => "katello_content_views_organization_fk"
  end
end
