class AddRepositoryLibraryId < ActiveRecord::Migration
  def self.up
      change_table :repositories do |t|
          t.integer :library_instance_id, :null=>true
      end
      Repository.reset_column_information
      User.current = User.hidden.first
      Repository.all.each do |lib_repo|
        if lib_repo.environment.library?
          KTEnvironment.where(:organization_id=>lib_repo.organization.id).each do |env|
            if lib_repo.is_cloned_in?(env)
              clone = lib_repo.get_clone(env)
              clone.library_instance_id = lib_repo.id
              clone.save!
            end
          end
        end
      end
  end

  def self.down
      remove_column :repositories, :library_instance_id
  end
end
