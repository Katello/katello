class AddErrataCounts < ActiveRecord::Migration
  def up
    add_column :katello_content_facets, :installable_security_errata_count, :integer, :null => false, :default => 0
    add_column :katello_content_facets, :installable_enhancement_errata_count, :integer, :null => false, :default => 0
    add_column :katello_content_facets, :installable_bugfix_errata_count, :integer, :null => false, :default => 0

    add_column :katello_content_facets, :applicable_rpm_count, :integer, :null => false, :default => 0
    add_column :katello_content_facets, :upgradable_rpm_count, :integer, :null => false, :default => 0

    Katello::Host::ContentFacet.find_each do |content_facet|
      content_facet.update_applicability_counts
    end
  end

  def down
    remove_column :katello_content_facets, :installable_security_errata_count
    remove_column :katello_content_facets, :installable_enhancement_errata_count
    remove_column :katello_content_facets, :installable_bugfix_errata_count

    remove_column :katello_content_facets, :applicable_rpm_count
    remove_column :katello_content_facets, :upgradable_rpm_count
  end
end
