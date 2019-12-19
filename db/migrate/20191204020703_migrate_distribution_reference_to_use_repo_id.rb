class MigrateDistributionReferenceToUseRepoId < ActiveRecord::Migration[5.2]
  class DistributionReference < Katello::Model
    self.table_name = 'katello_distribution_references'
  end

  def up
    #this was done before being deployed in production, so this should be okay,
    # although existing pulp3 repos will not work properly
    DistributionReference.destroy_all

    #work around sqlite add_column with non_null issue
    add_column :katello_distribution_references, :repository_id, :integer, :index => true
    change_column :katello_distribution_references, :repository_id, :integer, :null => false

    remove_column :katello_distribution_references, :root_repository_id
    add_foreign_key :katello_distribution_references, :katello_repositories, :column => :repository_id, :primary_key => :id
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
