class AddSystemInfoKeyToOrganizations < ActiveRecord::Migration

  class Organization < ActiveRecord::Base
  end

  def self.up
    add_column :organizations, :system_info_keys, :text
    Organization.reset_column_information
    Organization.where(:system_info_keys => nil).each do |o|
      o.system_info_keys = []
      o.save!
    end
  end

  def self.down
    remove_column :organizations, :system_info_keys
  end
end
