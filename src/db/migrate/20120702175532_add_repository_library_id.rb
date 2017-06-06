
class AddRepositoryLibraryId < ActiveRecord::Migration
  def self.up
      change_table :repositories do |t|
          t.integer :library_instance_id, :null=>true
      end
      Repository.reset_column_information
      User.current = User.hidden.first

      Repository.enabled.each do |lib_repo|
        if lib_repo.environment.library?
          Organization.all.each do |org|
            org.promotion_paths.each  do |path|
              process_path(lib_repo, path[0])
            end
          end
        end
      end
  end

  # Work-around for making the migration work for the code that
  # introduced label. When this migration is run, the label attribute
  # is not yet present in the database.
  def self.simulate_label(repo, env)
    target = env.organization.target unless env.nil?
    [repo, repo.product.target, env, target].each do |obj|
      obj.class_eval do
        def label; Util::Model::labelize(name) end
        def label=(*args); nil end
      end
    end
  end

  def self.process_path lib_repo, initial_env
    env = initial_env
    simulate_label(lib_repo, initial_env)
    clone = lib_repo.get_clone(initial_env)
    while clone
      env = env.successor
      simulate_label(clone, env)
      clone.library_instance_id = lib_repo.id
      clone.save!
      clone = env.nil? ? nil : clone.get_clone(env)
    end
  end

  def self.down
      remove_column :repositories, :library_instance_id
  end
end
