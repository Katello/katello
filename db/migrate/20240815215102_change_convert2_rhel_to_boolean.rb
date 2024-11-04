class ChangeConvert2RhelToBoolean < ActiveRecord::Migration[6.1]
  def up
    change_column :katello_subscription_facets, :convert2rhel_through_foreman, :boolean, using: 'convert2rhel_through_foreman::boolean'
  end

  def down
    change_column :katello_subscription_facets, :convert2rhel_through_foreman, :integer, using: 'convert2rhel_through_foreman::integer'
  end
end
