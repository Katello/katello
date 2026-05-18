class RemoveUuidFromContentFacets < ActiveRecord::Migration[7.0]
  def up
    # No data migration needed - subscription_facet.uuid is already the authoritative source
    # The ContentFacet model has delegation methods that automatically return subscription_facet.uuid
    # Any data in content_facet.uuid is either:
    # 1. Redundant (same as subscription_facet.uuid) - delegation handles it
    # 2. Stale/orphaned (different from subscription_facet.uuid) - should not be copied
    # 3. Present when subscription_facet.uuid is NULL - indicates unregistered/stale state
    remove_column :katello_content_facets, :uuid
  end

  def down
    add_column :katello_content_facets, :uuid, :string, limit: 255

    # Populate from subscription_facet on rollback
    execute <<-SQL
      UPDATE katello_content_facets cf
      SET uuid = sf.uuid
      FROM katello_subscription_facets sf
      WHERE sf.host_id = cf.host_id
        AND sf.uuid IS NOT NULL
    SQL
  end
end
