class AddFilenameToKatelloGenericContentUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_generic_content_units, :filename, :text
  end
end
