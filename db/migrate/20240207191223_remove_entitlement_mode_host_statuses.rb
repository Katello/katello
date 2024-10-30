class RemoveEntitlementModeHostStatuses < ActiveRecord::Migration[6.1]
  class FakeTablePreference < ApplicationRecord
    self.table_name = 'table_preferences'
    serialize :columns
  end

  def up
    obsolete_statuses = [
      "Katello::SubscriptionStatus",
      "Katello::PurposeStatus",
      "Katello::PurposeRoleStatus",
      "Katello::PurposeSlaStatus",
      "Katello::PurposeUsageStatus",
    ]

    ::HostStatus::Status.where(type: obsolete_statuses).delete_all

    FakeTablePreference.where(name: "hosts").each do |table_preference|
      next unless table_preference.columns.include?("subscription_status")
      new_columns = table_preference.columns - ["subscription_status"]
      if new_columns.present?
        table_preference.columns = new_columns
        table_preference.save(validate: false)
      else
        table_preference.destroy
      end
    end
  end
end
