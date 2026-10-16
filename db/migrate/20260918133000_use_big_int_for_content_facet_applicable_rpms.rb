class UseBigIntForContentFacetApplicableRpms < ActiveRecord::Migration[7.0]
  def up
    change_column :katello_content_facet_applicable_rpms, :rpm_id, :bigint
  end

  def down
    change_column :katello_content_facet_applicable_rpms, :rpm_id, :integer
  end
end
