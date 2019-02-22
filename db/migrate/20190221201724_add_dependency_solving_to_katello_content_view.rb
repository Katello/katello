class AddDependencySolvingToKatelloContentView < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_content_views, :solve_dependencies, :boolean, default: false
  end
end
