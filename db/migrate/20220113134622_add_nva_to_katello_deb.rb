class AddNvaToKatelloDeb < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_debs, :nva, :string
  end
end
