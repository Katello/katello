class RemoveDistributionUuid < ActiveRecord::Migration[6.0]
  def change
    remove_column :katello_repositories, :distribution_uuid, :string
  end
end
