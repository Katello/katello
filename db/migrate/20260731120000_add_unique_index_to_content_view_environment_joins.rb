class AddUniqueIndexToContentViewEnvironmentJoins < ActiveRecord::Migration[6.1]
  def up
    remove_duplicate_content_view_environment_content_facets
    remove_duplicate_content_view_environment_activation_keys

    add_index :katello_content_view_environment_content_facets,
              [:content_facet_id, :content_view_environment_id],
              :unique => true,
              :name => :index_cvenv_content_facets_on_facet_and_cvenv

    add_index :katello_content_view_environment_activation_keys,
              [:activation_key_id, :content_view_environment_id],
              :unique => true,
              :name => :index_cvenv_activation_keys_on_key_and_cvenv
  end

  def down
    remove_index :katello_content_view_environment_content_facets,
                 :name => :index_cvenv_content_facets_on_facet_and_cvenv
    remove_index :katello_content_view_environment_activation_keys,
                 :name => :index_cvenv_activation_keys_on_key_and_cvenv
  end

  private

  def remove_duplicate_content_view_environment_content_facets
    remove_duplicates(
      Katello::ContentViewEnvironmentContentFacet,
      :content_facet_id,
      :content_view_environment_id
    )
  end

  def remove_duplicate_content_view_environment_activation_keys
    remove_duplicates(
      Katello::ContentViewEnvironmentActivationKey,
      :activation_key_id,
      :content_view_environment_id
    )
  end

  # Keep the row with the lowest priority (id as tie-breaker); delete the rest.
  # unscoped avoids default_scope ORDER BY priority leaking into GROUP BY on PostgreSQL.
  def remove_duplicates(model, *group_columns)
    model.unscoped.group(*group_columns).having('COUNT(*) > 1').pluck(*group_columns).each do |group_values|
      group_values = Array(group_values)
      ids = model.unscoped
                 .where(group_columns.zip(group_values).to_h)
                 .order(:priority, :id)
                 .pluck(:id)
      model.unscoped.where(id: ids.drop(1)).delete_all
    end
  end
end
