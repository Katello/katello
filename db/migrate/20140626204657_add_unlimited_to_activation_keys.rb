class AddUnlimitedToActivationKeys < ActiveRecord::Migration[4.2]
  class ::Katello::ActivationKeys < ApplicationRecord
  end

  def up
    add_column :katello_activation_keys, :unlimited_content_hosts, :boolean, :default => true
    rename_column :katello_activation_keys, :usage_limit, :max_content_hosts
    change_column_default :katello_activation_keys, :max_content_hosts, nil

    Katello::ActivationKeys.reset_column_information
    Katello::ActivationKeys.all.each do |coll|
      if coll.max_content_hosts == -1
        coll.update_attributes(:unlimited_content_hosts => true, :max_content_hosts => nil)
      elsif coll.max_content_hosts > 0
        coll.update_attributes(:unlimited_content_hosts => false)
      end
    end
  end

  def down
    Katello::ActivationKeys.all.each do |key|
      key.update_attributes(:max_content_hosts => -1) if key.unlimited_content_hosts
    end

    remove_column :katello_activation_keys, :unlimited_content_hosts
    rename_column :katello_activation_keys, :max_content_hosts, :usage_limit
    change_column_default :katello_activation_keys, :usage_limit, -1
  end
end
