class CreateProviders < ActiveRecord::Migration
  def self.up
    create_table :providers do |t|
      t.string  :name
      t.string  :description
      t.string  :repository_url
      t.string  :provider_type
      t.references :organization, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :providers
  end
end
