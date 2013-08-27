class MoreGenericOrganizationDefaultInfo < ActiveRecord::Migration

  class Organization < ActiveRecord::Base
    # to keep all the validation from screaming
  end

  def self.up
    Organization.class_eval { serialize :default_info }
    add_column :organizations, :default_info, :text
    Organization.reset_column_information
    Organization.all.each do |org|
      org.default_info = Hash.new
      org.default_info["system"] = YAML.load(org[:system_info_keys])
      org.save!
    end
    remove_column :organizations, :system_info_keys
  end

  def self.down
    Organization.class_eval { serialize :system_info_keys }
    add_column :organizations, :system_info_keys, :text
    Organization.reset_column_information
    Organization.all.each do |org|
      org.system_default_info = YAML.load(org.default_info)["system"]
      org.save!
    end
    remove_column :organizations, :info_keys
  end
end
