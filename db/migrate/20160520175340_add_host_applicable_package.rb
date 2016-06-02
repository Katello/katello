class AddHostApplicablePackage < ActiveRecord::Migration
  def change
    create_table "katello_content_facet_applicable_rpms" do |t|
      t.references 'content_facet', :null => false
      t.references 'rpm', :null => false
    end

    add_index "katello_content_facet_applicable_rpms", ["rpm_id", "content_facet_id"],
              :name => "katello_content_facet_rpm_rid_cfid", :unique => true
  end
end
