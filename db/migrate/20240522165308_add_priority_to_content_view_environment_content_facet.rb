class AddPriorityToContentViewEnvironmentContentFacet < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_content_view_environment_content_facets, :priority, :integer, default: 0, null: false
  end
end
