class AddAllowOtherTypesToContentViewErratumFilterRules < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_content_view_erratum_filter_rules, :allow_other_types, :boolean,
      :default => false, :null => false
  end
end
