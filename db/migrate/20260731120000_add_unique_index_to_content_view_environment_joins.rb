class AddUniqueIndexToContentViewEnvironmentJoins < ActiveRecord::Migration[6.1]
  def up
    remove_duplicate_content_view_environment_content_facets
    remove_duplicate_content_view_environment_activation_keys

    add_index :katello_content_view_environment_content_facets,
              [:content_facet_id, :content_view_environment_id],
              :unique => true,
              :name => :index_cve_content_facets_on_facet_and_cve

    add_index :katello_content_view_environment_activation_keys,
              [:activation_key_id, :content_view_environment_id],
              :unique => true,
              :name => :index_cve_activation_keys_on_key_and_cve
  end

  def down
    remove_index :katello_content_view_environment_content_facets,
                 :name => :index_cve_content_facets_on_facet_and_cve
    remove_index :katello_content_view_environment_activation_keys,
                 :name => :index_cve_activation_keys_on_key_and_cve
  end

  private

  def remove_duplicate_content_view_environment_content_facets
    execute(<<~SQL.squish)
      DELETE FROM katello_content_view_environment_content_facets
      WHERE id IN (
        SELECT id
        FROM (
          SELECT id,
                 ROW_NUMBER() OVER (
                   PARTITION BY content_facet_id, content_view_environment_id
                   ORDER BY id
                 ) AS duplicate_rank
          FROM katello_content_view_environment_content_facets
        ) duplicate_rows
        WHERE duplicate_rank > 1
      )
    SQL
  end

  def remove_duplicate_content_view_environment_activation_keys
    execute(<<~SQL.squish)
      DELETE FROM katello_content_view_environment_activation_keys
      WHERE id IN (
        SELECT id
        FROM (
          SELECT id,
                 ROW_NUMBER() OVER (
                   PARTITION BY activation_key_id, content_view_environment_id
                   ORDER BY id
                 ) AS duplicate_rank
          FROM katello_content_view_environment_activation_keys
        ) duplicate_rows
        WHERE duplicate_rank > 1
      )
    SQL
  end
end
