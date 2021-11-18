class RemoveDependencySolvingAlgorithmSetting < ActiveRecord::Migration[6.0]
  def change
    Setting.where(:name => 'dependency_solving_algorithm', :category => 'Setting::Content').delete_all
  end
end
