class MoreGenericOrganizationInfoKeys < ActiveRecord::Migration

  class Organization < ActiveRecord::Base
    # to keep all the validation from screaming
  end

  def self.up
    Organization.class_eval { serialize :info_keys }
    add_column :organizations, :info_keys, :text
    Organization.reset_column_information
    Organization.all.each do |org|
      org.info_keys = Hash.new
      org.info_keys["system"] = YAML::load(org[:system_info_keys])
      org.info_keys["subscription"] = []
      org.save!
    end
    remove_column :organizations, :system_info_keys
  end

  def self.down
    Organization.class_eval { serialize :system_info_keys }
    add_column :organizations, :system_info_keys, :text
    Organization.reset_column_information
    Organization.all.each do |org|
      org.system_info_keys = YAML::load(org.info_keys)["system"]
      org.save!
    end
    remove_column :organizations, :info_keys
  end
end
