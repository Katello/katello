class AddDateTypeToContentViewErratumFilterRules < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_content_view_erratum_filter_rules, :date_type, :string,
      :default => "updated", :null => false, :limit => 255
    update "UPDATE katello_content_view_erratum_filter_rules SET date_type = 'issued'"
  end
end
