class UpdateSystemPurposeStatus < ActiveRecord::Migration[6.0]
  def change
    purpose_types = [
      "Katello::PurposeStatus",
      "Katello::PurposeAddonsStatus",
      "Katello::PurposeRoleStatus",
      "Katello::PurposeSlaStatus",
      "Katello::PurposeUsageStatus"
    ]

    # load both sets of host statuses and *then* update them to make sure we update the correct statuses
    unknown_statuses = ::HostStatus::Status.where(type: purpose_types, status: 2).pluck(:id)
    matched_statuses = ::HostStatus::Status.where(type: purpose_types, status: 0).pluck(:id)

    ::HostStatus::Status.where(id: unknown_statuses).update_all(status: 0) # 2 => 0
    ::HostStatus::Status.where(id: matched_statuses).update_all(status: 2) # 0 => 2
  end
end
