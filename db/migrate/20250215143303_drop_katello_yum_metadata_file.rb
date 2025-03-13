class DropKatelloYumMetadataFile < ActiveRecord::Migration[7.0]
  def change
    drop_table :katello_yum_metadata_files
  end
end
