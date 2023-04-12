class AddAppliedFiltersToKatelloContentViewVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_content_view_versions, :applied_filters, :jsonb
  end
end
