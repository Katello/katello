class AddReqeustType < ActiveRecord::Migration
  def self.up
    add_column :notices, :request_type, :string
  end

  def self.down
    remove_column :notices, :request_type
  end
end
