class ChangeEnvironmentPrior < ActiveRecord::Migration[4.2]
  def up
    add_column :katello_environment_priors, :id, :primary_key
  end

  def down
    remove_column :katello_environment_priors, :id
  end
end
