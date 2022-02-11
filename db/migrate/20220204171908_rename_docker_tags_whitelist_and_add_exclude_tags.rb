class RenameDockerTagsWhitelistAndAddExcludeTags < ActiveRecord::Migration[6.0]
  def change
    change_table :katello_root_repositories do |t|
      t.rename :docker_tags_whitelist, :include_tags
      t.text :exclude_tags
    end
  end
end
