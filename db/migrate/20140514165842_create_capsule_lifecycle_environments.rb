class CreateCapsuleLifecycleEnvironments < ActiveRecord::Migration
  def change
    create_table :katello_capsule_lifecycle_environments do |t|
      t.references :capsule
      t.references :lifecycle_environment
    end

    add_index :katello_capsule_lifecycle_environments, [:capsule_id],
              :name => :index_cle_on_capsule_id
    add_index :katello_capsule_lifecycle_environments, [:lifecycle_environment_id],
              :name => :index_cle_on_lifecycle_environment_id
  end
end
