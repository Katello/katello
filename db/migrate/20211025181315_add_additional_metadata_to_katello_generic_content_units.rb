class AddAdditionalMetadataToKatelloGenericContentUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_generic_content_units, :additional_metadata, :jsonb
  end
end
