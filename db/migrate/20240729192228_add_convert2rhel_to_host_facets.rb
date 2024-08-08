class AddConvert2rhelToHostFacets < ActiveRecord::Migration[6.1]
  def up
    add_column :katello_subscription_facets, :convert2rhel_through_foreman, :int4
  end

  def down
    remove_column :subscription_facets, :convert2rhel_through_foreman
  end
end
