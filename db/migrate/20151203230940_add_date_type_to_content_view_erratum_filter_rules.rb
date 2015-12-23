class AddDateTypeToContentViewErratumFilterRules < ActiveRecord::Migration
  def change
    add_column :katello_content_view_erratum_filter_rules, :date_type, :string, :default => "updated", :null => false
    update "UPDATE katello_content_view_erratum_filter_rules SET date_type = 'issued'"
  end
end
