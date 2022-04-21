class RemoveDependencySolvingAlgorithmSetting < ActiveRecord::Migration[6.0]
  def change
    Setting.where(:name => 'dependency_solving_algorithm').delete_all
  end
end
