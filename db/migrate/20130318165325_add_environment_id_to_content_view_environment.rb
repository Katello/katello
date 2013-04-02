class AddEnvironmentIdToContentViewEnvironment < ActiveRecord::Migration
  def self.up
    #adds environment_id to content_view_environment so we can query
    #  and don't have to split the cp_id to find the environment
    add_column :content_view_environments, :environment_id, :integer, :null=>true
    ContentViewEnvironment.reset_column_information
    ContentViewEnvironment.all.each do |cve|
      env_id = cve.cp_id.split('-').first
      cve.environment_id = env_id
      cve.save!
    end
    change_column :content_view_environments, :environment_id, :integer, :null=>false
    add_index :content_view_environments, :environment_id
  end

  def self.down
    remove_index :content_view_environments, :environment_id
    remove_column :content_view_environments, :environment_id
  end
end
