class DeleteOldSettingData < ActiveRecord::Migration[6.0]
  def up
    Setting.where(name: ['default_location_puppet_content', 'pulp_sync_node_action_accept_timeout',
                         'pulp_sync_node_action_finish_timeout', 'subscriptions_return_host_data']).delete_all
  end

  def down
  end
end
